#lang racket
(require redex)

(provide Flux)

(define-language Flux

  ;; Packages
  ;; --------
  (PackageClause ("package" Identifier))
  (File StatementList
        (PackageClause StatementList)
        (ImportList StatementList)
        (PackageClause ImportList StatementList))
  (ImportList (ImportDeclaration ...))
  (ImportDeclaration ("import" StringLit)
                     ("import" Identifier StringLit))

  ;; Blocks
  ;; ------
  (Block 𝒰
         PackageBlock
         FileBlock
         FunctionLitBlock
         ("{" StatementList "}" ))

  ;; Statements
  ;; ----------
  (StatementList (Statement ...))
  (Statement OptionAssignment
             VariableAssignment
             ReturnStatement
             ExpressionStatement)

  ;; OptionAssignment = "option" [ identifier "." ] identifier "=" Expression .
  (OptionAssignment ("option" OptionPath "=" Expression))
  (OptionPath Identifier (Identifier "." Identifier))

  
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

  ;; Literals
  ;; --------
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

  ;; FIXME
  (DateTimeLit date (date "T" time))
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
  ;; FIXME
  (timeOffset "Z"
              ("+" hour ":" minute)
              ("-" hour ":" minute))

  (RecordLit ("{" RecordBody "}"))
  (RecordBody WithProperties PropertyList)
  (WithProperties (Identifier "with" PropertyList))
  ;; PropertyList   = [ Property { "," Property } ] .
  ;; FIXME could be empty?
  (PropertyList (Property ...))
  ;; Property       = identifier [ ":" Expression ]
  ;;                | string_lit ":" Expression .
  ;; FIXME
  (Property Identifier
            (Identifier ":" Expression)
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
  (Parameter Identifier (Identifier "=" Expression))

  (FunctionBody Expression Block)

  (CallExpression ( "(" PropertyList ")" ))

  (PipeReceiveLit "<-")

  (IndexExpression ("[" Expression "]"))

  (MemberExpression DotExpression MemberBracketExpression)
  (DotExpression ("." Identifier))
  (MemberBracketExpression ("[" StringLit "]"))

  ;; Operators
  ;; ---------
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
  ;; -----------
  ;;
  ;; (Includes operator precedence)
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
                            (ExponentExpression MultiplicativeOperator MultiplicativeExpression))

  (ExponentExpression PipeExpression
                      (ExponentExpression ExponentOperator PipeExpression))

  (PipeExpression PostfixExpression
                  (PipeExpression PipeOperator UnaryExpression))

  (UnaryExpression PostfixExpression
                   (PrefixOperator UnaryExpression))

  (PostfixExpression PrimaryExpression
                     (PostfixExpression PostfixOperator))
  )
