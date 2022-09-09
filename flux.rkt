#lang racket
(require redex)

(provide Flux)

(define-language Flux

  (packageClause ("package" identifier))

  ;; File = [ PackageClause ] [ ImportList ] StatementList .
  (File (packageClause importList statementList))

  (importList (importDeclaration ...))
  ;; TODO ImportDeclaration = "import" [identifier] string_lit .
  (importDeclaration ("import"  string_lit))

  ;; See https://docs.influxdata.com/flux/v0.x/spec/blocks/
  (block 𝒰
         packageBlock
         fileBlock
         functionLitBlock
         ("{" statementList "}" ))

  (statementList (statement ...))
  (statement optionAssignment
             builtinStatement
             variableAssignment
             returnStatement
             expressionStatement)

  ;; OptionAssignment = "option" [ identifier "." ] identifier "=" Expression .
  (optionAssignment ("option" identifier "=" expression))

  ;; BuiltinStatement = "builtin" identifer ":" TypeExpression .
  (builtinStatement ("builtin" identifier ":" TypeExpression))
  ;; TypeExpression   = MonoType ["where" Constraints] .
  (TypeExpression MonoType (MonoType "where" Constraints))
  ;; MonoType = Tvar | Basic | Array | Record | Function .
  (MonoType Tvar Basic Array Record Function)
  ;; Tvar     = "A" … "Z" .
  (Tvar string)                         ;fixme
  ;; Basic    = "int" | "uint" | "float" | "string" | "bool" | "time" | "duration" | "bytes" | "regexp" .
  (Basic "int" "uint" "float" "string" "bool" "time" "duration") ; TODO bytes and regex
  ;; Array    = "[" MonoType "]" .
  (Array ("[" MonoType "]"))
  ;; Record   = ( "{" [Properties] "}" ) | ( "{" Tvar "with" Properties "}" ) .
  (Record ("{" (Properties ...) "}") ("{" Tvar "with" Properties "}") )
  ;; Function = "(" [Parameters] ")" "=>" MonoType .
  (Function ("(" Parameters ")" "=>" MonoType))
  ;; Properties = Property { "," Property } .
  (Properties (Property ...))
  ;; Property   = identifier ":" MonoType .
  (Property (identifer ":" MonoType))
  ;; Parameters = Parameter { "," Parameter } .
  (Parameters (Parameter ...))
  ;; Parameter  = [ "<-" | "?" ] identifier ":" MonoType .
  (Parameter ("<-" identifier ":" MonoType)
             ("?" identifier ":" MonoType))
  ;; Constraints = Constraint { "," Constraint } .
  (Constraints (Constraint ...))
  ;; Constraint  = Tvar ":" Kinds .
  (Constraint (Tvar ":" Kinds))
  ;; Kinds       = identifier { "+" identifier } .
  ;; FIXME
  (Kinds identifer)
  
  (variableAssignment (identifier "=" expression))

  (returnStatement ("return" expression))

  (expressionStatement expression)

  (primaryExpression identifier
                     literal
                     ("(" expression ")"))

  ;; identifier (letter { letter | unicode_digit } .
  ;; (identifier (letter (letter ))
  (identifier variable-not-otherwise-mentioned)

  (digit "0" "1" "2" "3" "4" "5" "6" "7" "8" "9")

  (literal intLit
           floatLit
           stringLit
           ;; regexLit
           durationLit
           datetimeLit
           pipeReceiveLit
           recordLit
           arrayLit
           dictLit
           functionLit)

  (intLit integer)

  (floatLit real)

  (stringLit string)

  ;; TODO maybe?
  ;; (regexLit)

  (durationLit (intLit durationUnit))
  (durationUnit "y" "mo" "w" "d" "h" "m" "s" "ms" "us" "μs" "ns")

  ;; date_time_lit     = date [ "T" time ] .
  (datetimeLit (date "T" time))

  ;; RecordLiteral  = "{" RecordBody "}" .
  (recordLit ("{" recordBody "}"))
  ;; RecordBody     = WithProperties | PropertyList .
  (recordBody withProperties propertyList)
  ;; WithProperties = identifier "with" PropertyList .
  (withProperties (identifier "with" propertyList))
  ;; PropertyList   = [ Property { "," Property } ] .
  (propertyList (property ...))
  ;; Property       = identifier [ ":" Expression ]
  ;;                | string_lit ":" Expression .
  (property (identifier ":" expression)
            (stringLit ":" expression))

  (arrayLit ("[" expressionList "]"))
  (expressionList (expression ...))

  ;; DictLiteral     = EmptyDict | "[" AssociativeList "]" .
  (dictLit emptyDict
           ("[" associativeList "]"))
  (emptyDict ("[" ":" "]"))
  ;; AssociativeList = Association { "," AssociativeList } .
  (associativeList (association ...))
  ;; Association     = Expression ":" Expression .
  (association (expression ":" expression))
  
  ;; FunctionLiteral    = FunctionParameters "=>" FunctionBody .
  (functionLit (functionParameters "=>" functionBody))

  ;; FunctionParameters = "(" [ ParameterList [ "," ] ] ")" .
  ;; TODO this done definitely needs to be zero or more
  (functionParameters ( "(" parameterList ")" )
                      emptyParamList
                      )
  (emptyParamList "()")

  ;; ParameterList      = Parameter { "," Parameter } .
  (parameterList (parameter ...))

  ;; Parameter          = identifier [ "=" Expression ] .
  ;; TODO multiple parameters
  (parameter identifier)

  ;; FunctionBody       = Expression | Block .
  (functionBody expression block)

  ;; CallExpression = "(" PropertyList ")" .
  (callExpression ( "(" propertyList ")" ))

  (pipeReceiveLit "<-")

  ;; IndexExpression = "[" Expression "]" .
  (indexExpression ("[" expression "]"))

  (memberExpression dotExpression memberBracketExpression)
  (dotExpression ("." identifier))
  (memberBracketExpression ("[" stringLit "]"))

  ;; 
  ;; date              = year "-" month "-" day .
  (date (year "-" month "-" day))
  ;; TODO for these, maybe we can escape to Racket for a length check?
  ;; year              = decimal_digit decimal_digit decimal_digit decimal_digit .
  (year (digit digit digit digit))
  ;; month             = decimal_digit decimal_digit .
  (month (digit digit))
  ;; day               = decimal_digit decimal_digit .
  (day (digit digit))
  ;; time              = hour ":" minute ":" second [ fractional_second ] [ time_offset ] .
  (time (hour ":" minute ":" second))
  ;; hour              = decimal_digit decimal_digit .
  (hour (digit digit))
  ;; minute            = decimal_digit decimal_digit .
  (minute (digit digit))
  ;; second            = decimal_digit decimal_digit .
  (second (digit digit))
  ;; fractional_second = "."  { decimal_digit } .
  ;; (fractionalSecond ("." digit))
  ;; time_offset       = "Z" | ("+" | "-" ) hour ":" minute .
  ;; (timeOffset ())

  ;; Operators
  (LogicalOperator "and" "or")

  (UnaryLogicalOperator "not" "exists")

  (ComparisonOperator "=="  "!="  "<"  "<="  ">"  ">="  "=~"  "!~")
  
  (AdditiveOperator "+" "-")
  
  (MultiplicativeOperator "*" "/" "%")
  
  (ExponentOperator "^")
  
  (PipeOperator "|>")
  
  (PrefixOperator "+" "-")

  (PostfixOperator memberExpression
                   callExpression
                   indexExpression)

  ;; Expressions
  ;;
  ;; Includes operator precedence
  (expression ConditionalExpression)

  (ConditionalExpression LogicalExpression
                         ("if" expression "then" expression "else" expression))
  
  (LogicalExpression UnaryLogicalExpression
                     (LogicalExpression LogicalOperator UnaryLogicalExpression))

  (UnaryLogicalExpression ComparisonExpression
                          (UnaryLogicalOperator UnaryLogicalExpression))

  (ComparisonExpression MultiplicativeExpression
                        (ComparisonExpression ComparisonOperator MultiplicativeExpression))

  (AdditiveExpression MultiplicativeExpression
                      (AdditiveExpression AdditiveOperator MultiplicativeExpression))

  (MultiplicativeExpression ExponentExpression
                            (ExponentExpression ExponentOperator MultiplicativeExpression)
                            (ExponentExpression MultiplicativeOperator MultiplicativeExpression))

  (ExponentExpression PipeExpression
                      (ExponentExpression ExponentOperator PipeExpression))

  (PipeExpression PostfixExpression
                  (PipeExpression PipeOperator UnaryExpression))

  (UnaryExpression PostfixExpression
                   (PrefixOperator UnaryExpression))

  (PostfixExpression primaryExpression
                     (PostfixExpression PostfixOperator))

  ;; ;; A type defines the set of values and operations on those values.
  ;; ;; Types are never explicitly declared as part of the syntax except as part of a builtin statement.
  ;; ;; Types are always inferred from the usage of the value.
  ;; ;; Type inference follows a Hindley-Milner style inference system.
  ;; ;;
  ;; ;; TODO union types? https://docs.influxdata.com/flux/v0.x/spec/types/#union-types
  ;; (type "null"
  ;;       Boolean
  ;;       integer ;; uint | int | float

  ;;       Time
  ;;       duration

  ;;       string

  ;;       ;; bytes
  ;;       ;; regex

  ;;       array
  ;;       record
  ;;       dictionary
  ;;       function
  ;;       generator
  ;;       )

  ;;   (Boolean boolean "null")

  ;;   (typeConstraint addable
  ;;                   subtractable
  ;;                   divisable
  ;;                   numeric
  ;;                   comparable
  ;;                   equatable
  ;;                   nullable
  ;;                   record
  ;;                   negatable
  ;;                   timeable
  ;;                   stringable)
  )
