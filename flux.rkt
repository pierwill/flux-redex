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
  (Statement OptionAssignment
             BuiltinStatement
             VariableAssignment
             ReturnStatement
             ExpressionStatement)

  ;; OptionAssignment = "option" [ identifier "." ] identifier "=" Expression .
  (OptionAssignment ("option" Identifier "=" Expression))

  (BuiltinStatement ("builtin" Identifier ":" TypeExpression))

  ;; TODO does this all belong to/in the type system?
  ;; TypeExpression   = MonoType ["where" Constraints] .
  (TypeExpression MonoType (MonoType "where" Constraints))
  (MonoType Tvar Basic Array Record Function)
  ;; Tvar     = "A" … "Z" .
  ;; FIXME
  (Tvar string)
  (Basic "int" "uint" "float" "string" "bool" "time" "duration") ; TODO "bytes" and "regex"
  (Array ("[" MonoType "]"))
  ;; Record   = ( "{" [Properties] "}" ) | ( "{" Tvar "with" Properties "}" ) .
  ;; FIXME
  (Record ("{" (Properties ...) "}") ("{" Tvar "with" Properties "}") )
  ;; Function = "(" [Parameters] ")" "=>" MonoType .
  ;; FIXME
  (Function ("(" Parameters ")" "=>" MonoType))
  ;; Properties = Property { "," Property } .
  (Properties (Property-in-builtin ...))
  ;; TODO defining property twice?
  (Property-in-builtin (Label ":" MonoType))
  (Label Identifier StringLit)
  ;; Parameters = Parameter { "," Parameter } .
  (Parameters (Parameter-in-builtin ...))
  ;; Parameter  = [ "<-" | "?" ] identifier ":" MonoType .
  ;; FIXME
  (Parameter-in-builtin ("<-" Identifier ":" MonoType)
             ("?" Identifier ":" MonoType))
  ;; Constraints = Constraint { "," Constraint } .
  (Constraints (Constraint ...))
  (Constraint (Tvar ":" Kinds))
  ;; Kinds       = identifier { "+" identifier } .
  ;; FIXME
  (Kinds Identifier)
  
  (VariableAssignment (Identifier "=" Expression))

  (ReturnStatement ("return" Expression))

  (ExpressionStatement Expression)

  (PrimaryExpression Identifier
                     Literal
                     ("(" Expression ")"))

  ;; TODO decide how to handle this
  ;; identifier (letter { letter | unicode_digit } .
  ;; (identifier (letter (letter ))
  (Identifier variable-not-otherwise-mentioned)

  (digit "0" "1" "2" "3" "4" "5" "6" "7" "8" "9")

  (Literal IntLit
           FloatLit
           StringLit
           ;; regexLit
           DateTimeLit
           DurationLit
           PipeReceiveLit
           RecordLit
           ArrayLit
           DictLit
           FunctionLit)

  (IntLit integer)

  ;; TODO digits?
  ;; float_lit = decimals "." [ decimals ]
  ;;     | "." decimals .
  ;; decimals  = decimal_digit { decimal_digit } .
  (FloatLit real)

  (StringLit string)

  ;; TODO maybe?
  ;; (regexLit)

  (DurationLit (durationMagnitude durationUnit))
  (durationMagnitude integer)
  (durationUnit "y" "mo" "w" "d" "h" "m" "s" "ms" "us" "μs" "ns")

  ;; date_time_lit     = date [ "T" time ] .
  ;; FIXME
  (DateTimeLit (date "T" time))
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

  (RecordLit ("{" RecordBody "}"))
  (RecordBody WithProperties PropertyList)
  (WithProperties (Identifier "with" PropertyList))
  ;; PropertyList   = [ Property { "," Property } ] .
  ;; FIXME
  (PropertyList (Property ...))
  ;; Property       = identifier [ ":" Expression ]
  ;;                | string_lit ":" Expression .
  ;; FIXME
  (Property (Identifier ":" Expression)
            (StringLit ":" Expression))

  (ArrayLit ("[" expressionList "]"))
  (expressionList (Expression ...))

  (DictLit EmptyDict
           ("[" AssociativeList "]"))
  (EmptyDict ("[" ":" "]"))
  ;; AssociativeList = Association { "," AssociativeList } .
  (AssociativeList (Association ...))
  (Association (Expression ":" Expression))
  
  (FunctionLit (FunctionParameters "=>" FunctionBody))

  ;; FunctionParameters = "(" [ ParameterList [ "," ] ] ")" .
  ;; FIXME
  (FunctionParameters ( "(" ParameterList ")" )
                      emptyParamList
                      )
  (emptyParamList "()")

  ;; ParameterList      = Parameter { "," Parameter } .
  ;; TODO check me
  (ParameterList (Parameter ...))

  ;; Parameter          = identifier [ "=" Expression ] .
  ;; FIXME multiple parameters
  (Parameter Identifier)

  (FunctionBody Expression Block)

  (CallExpression ( "(" PropertyList ")" ))

  (PipeReceiveLit "<-")

  (IndexExpression ("[" Expression "]"))

  (MemberExpression DotExpression MemberBracketExpression)
  (DotExpression ("." Identifier))
  (MemberBracketExpression ("[" StringLit "]"))


  ;; Operators
  (LogicalOperator "and" "or")

  (UnaryLogicalOperator "not" "exists")

  (ComparisonOperator "=="  "!="  "<"  "<="  ">"  ">="  "=~"  "!~")
  
  (AdditiveOperator "+" "-")
  
  (MultiplicativeOperator "*" "/" "%")
  
  (ExponentOperator "^")
  
  (PipeOperator "|>")
  
  (PrefixOperator "+" "-")

  (PostfixOperator MemberExpression
                   CallExpression
                   IndexExpression)

  ;; Expressions
  ;;
  ;; Includes operator precedence
  (Expression ConditionalExpression)

  (ConditionalExpression LogicalExpression
                         ("if" Expression "then" Expression "else" Expression))
  
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

  (PostfixExpression PrimaryExpression
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
