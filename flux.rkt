#lang racket
(require redex)

(provide Flux)

(define-language Flux

  (PackageClause ("package" Identifier))
  ;; File = [ PackageClause ] [ ImportList ] StatementList .
  (File (PackageClause ImportList StatementList))
  (ImportList (ImportDeclaration ...))
  ;; ImportDeclaration = "import" [identifier] string_lit .
  ;; FIXME
  (ImportDeclaration ("import" string_lit))

  ;; Blocks
  ;; See https://docs.influxdata.com/flux/v0.x/spec/blocks/
  (Block 𝒰
         PackageBlock
         FileBlock
         FunctionLitBlock
         ("{" StatementList "}" ))

  ;; Statements
  (StatementList (Statement ...))
  (Statement optionAssignment
             builtinStatement
             variableAssignment
             returnStatement
             expressionStatement)

  ;; OptionAssignment = "option" [ identifier "." ] identifier "=" Expression .
  (optionAssignment ("option" Identifier "=" expression))

  (builtinStatement ("builtin" Identifier ":" TypeExpression))
  ;; TypeExpression   = MonoType ["where" Constraints] .
  (TypeExpression MonoType (MonoType "where" Constraints))
  (MonoType Tvar Basic Array Record Function)
  ;; Tvar     = "A" … "Z" .
  ;; FIXME
  (Tvar string)
  (Basic "int" "uint" "float" "string" "bool" "time" "duration") ; TODO "bytes" and "regex"
  (Array ("[" MonoType "]"))
  ;; Record   = ( "{" [Properties] "}" ) | ( "{" Tvar "with" Properties "}" ) .
  (Record ("{" (Properties ...) "}") ("{" Tvar "with" Properties "}") )
  ;; Function = "(" [Parameters] ")" "=>" MonoType .
  (Function ("(" Parameters ")" "=>" MonoType))
  ;; Properties = Property { "," Property } .
  (Properties (Property ...))
  (Property (Label ":" MonoType))
  (Label Identifier stringLit)
  ;; Parameters = Parameter { "," Parameter } .
  (Parameters (Parameter ...))
  ;; Parameter  = [ "<-" | "?" ] identifier ":" MonoType .
  ;; FIXME
  (Parameter ("<-" Identifier ":" MonoType)
             ("?" Identifier ":" MonoType))
  ;; Constraints = Constraint { "," Constraint } .
  (Constraints (Constraint ...))
  (Constraint (Tvar ":" Kinds))
  ;; Kinds       = identifier { "+" identifier } .
  ;; FIXME
  (Kinds Identifier)
  
  (variableAssignment (Identifier "=" expression))

  (returnStatement ("return" expression))

  (expressionStatement expression)

  (primaryExpression Identifier
                     literal
                     ("(" expression ")"))

  ;; TODO decide how to handle this
  ;; identifier (letter { letter | unicode_digit } .
  ;; (identifier (letter (letter ))
  (Identifier variable-not-otherwise-mentioned)

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

  ;; TODO digits?
  ;; float_lit = decimals "." [ decimals ]
  ;;     | "." decimals .
  ;; decimals  = decimal_digit { decimal_digit } .
  (floatLit real)

  (stringLit string)

  ;; TODO maybe?
  ;; (regexLit)

  (durationLit (durationMagnitude durationUnit))
  (durationMagnitude integer)
  (durationUnit "y" "mo" "w" "d" "h" "m" "s" "ms" "us" "μs" "ns")

  ;; date_time_lit     = date [ "T" time ] .
  ;; FIXME
  (datetimeLit (date "T" time))
  (date (year "-" month "-" day))
  ;; TODO for these, maybe we can escape to Racket for a length check?
  ;; year              = decimal_digit decimal_digit decimal_digit decimal_digit .
  (year (digit digit digit digit))
  ;; month             = decimal_digit decimal_digit .
  (month (digit digit))
  ;; day               = decimal_digit decimal_digit .
  (day (digit digit))
  ;; time              = hour ":" minute ":" second [ fractional_second ] [ time_offset ] .
  ;; FIXME remove this hack
  (time (hour ":" minute ":" second)
        (hour ":" minute ":" second hack))
  (hack fractionalSecond timeOffset)
  ;; hour              = decimal_digit decimal_digit .
  (hour (digit digit))
  ;; minute            = decimal_digit decimal_digit .
  (minute (digit digit))
  ;; second            = decimal_digit decimal_digit .
  (second (digit digit))
  ;; fractional_second = "."  { decimal_digit } .
  (fractionalSecond ("." digit))
  ;; time_offset       = "Z" | ("+" | "-" ) hour ":" minute .
  (timeOffset ("Z" "+" hour ":" minute)
              ("Z" "-" hour ":" minute))

  (recordLit ("{" recordBody "}"))
  (recordBody withProperties propertyList)
  (withProperties (Identifier "with" propertyList))
  ;; PropertyList   = [ Property { "," Property } ] .
  ;; FIXME
  (propertyList (property ...))
  ;; Property       = identifier [ ":" Expression ]
  ;;                | string_lit ":" Expression .
  ;; FIXME
  (property (Identifier ":" expression)
            (stringLit ":" expression))

  (arrayLit ("[" expressionList "]"))
  (expressionList (expression ...))

  (dictLit emptyDict
           ("[" associativeList "]"))
  (emptyDict ("[" ":" "]"))
  ;; AssociativeList = Association { "," AssociativeList } .
  (associativeList (association ...))
  (association (expression ":" expression))
  
  (functionLit (functionParameters "=>" functionBody))

  ;; FunctionParameters = "(" [ ParameterList [ "," ] ] ")" .
  ;; FIXME
  (functionParameters ( "(" parameterList ")" )
                      emptyParamList
                      )
  (emptyParamList "()")

  ;; ParameterList      = Parameter { "," Parameter } .
  ;; TODO check me
  (parameterList (parameter ...))

  ;; Parameter          = identifier [ "=" Expression ] .
  ;; FIXME multiple parameters
  (parameter Identifier)

  (functionBody expression Block)

  (callExpression ( "(" propertyList ")" ))

  (pipeReceiveLit "<-")

  (indexExpression ("[" expression "]"))

  (memberExpression dotExpression memberBracketExpression)
  (dotExpression ("." Identifier))
  (memberBracketExpression ("[" stringLit "]"))


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
