#lang racket
(require redex)

(provide Flux)

(define-language Flux

  (packageClause ("package" identifier))

  ;; File = [ PackageClause ] [ ImportList ] StatementList .
  (file (packageClause importList statementList))

  ;; ImportList = { ImportDeclaration } .
  (importList (importDeclaration ...))

  ;; A type defines the set of values and operations on those values.
  ;; Types are never explicitly declared as part of the syntax except as part of a builtin statement.
  ;; Types are always inferred from the usage of the value.
  ;; Type inference follows a Hindley-Milner style inference system.
  ;;
  ;; TODO union types? https://docs.influxdata.com/flux/v0.x/spec/types/#union-types
  (type "null"
        Boolean
        integer ;; uint | int | float

        Time
        duration

        string

        ;; bytes
        ;; regex

        array
        record
        dictionary
        function
        generator
        )

  (Boolean boolean "null")

  (typeConstraint addable
                  subtractable
                  divisable
                  numeric
                  comparable
                  equatable
                  nullable
                  record
                  negatable
                  timeable
                  stringable)

  ;; In addition to explicit blocks in the source code, there are implicit blocks:
  ;;
  ;;   - The universe block encompasses all Flux source text.
  ;;   - Each package has a package block containing all Flux source text for that package.
  ;;   - Each file has a file block containing all Flux source text in that file.
  ;;   - Each function literal has its own function block even if not explicitly declared.
  ;;
  ;; Blocks nest and influence scoping.
  ;; https://docs.influxdata.com/flux/v0.x/spec/blocks/
  (block ("{" statementList "}" ))
  (statementList (statement ...))

  (statement optionAssignment
             builtinStatement
             variableAssignment
             returnStatement
             expressionStatement)

  ;; OptionAssignment = "option" [ identifier "." ] identifier "=" Expression .
  (optionAssignment ("option" identifier "=" expression))

  ;; (builtinStatement)

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
           ;; pipeReceiveLit
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

  ;; TODO
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

  ;; TODO
  ;; ArrayLiteral   = "[" ExpressionList "]" .
  ;; ExpressionList = [ Expression { "," Expression } ] .
  (arrayLit ("[" expressionList "]"))
  (expressionList (expression ...))

  ;; TODO
  ;; (dictLit)

  ;; FunctionLiteral    = FunctionParameters "=>" FunctionBody .
  (functionLit (functionParameters "=>" functionBody))

  ;; FunctionParameters = "(" [ ParameterList [ "," ] ] ")" .
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
  
  ;; date              = year "-" month "-" day .
  (date (year "-" month "-" day))
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

  (keyword "and" "import" "not" "return" "option" "test" "empty" "in" "or" "package" "builtin")

  (operators
   "+" "==" "!=" "(" ")" "=>" "-" "<" "!~" "[" "]" "^"
   "*" ">" "=~" "{" "}" "/" "<=" "=" "," ":" "%" ">=" "<-" "." "|>" )

  ;; Operator precedence
  ;; -------------------

  (expression ConditionalExpression)

  (ConditionalExpression LogicalExpression
                         ("if" expression "then" expression "else" expression))

  (LogicalExpression UnaryLogicalExpression
                     (LogicalExpression LogicalOperator UnaryLogicalExpression))

  (LogicalOperator "and" "or")

  (UnaryLogicalExpression ComparisonExpression
                          (UnaryLogicalOperator UnaryLogicalExpression))

  (UnaryLogicalOperator "not" "exists")

  (ComparisonExpression MultiplicativeExpression
                        (ComparisonExpression ComparisonOperator MultiplicativeExpression))

  (ComparisonOperator "=="  "!="  "<"  "<="  ">"  ">="  "=~"  "!~")

  (AdditiveExpression MultiplicativeExpression
                      (AdditiveExpression AdditiveOperator MultiplicativeExpression))

  (AdditiveOperator "+" "-")

  (MultiplicativeExpression ExponentExpression
                            (ExponentExpression ExponentOperator MultiplicativeExpression)
                            (ExponentExpression MultiplicativeOperator MultiplicativeExpression))

  (MultiplicativeOperator "*" "/" "%")

  (ExponentExpression PipeExpression
                      (ExponentExpression ExponentOperator PipeExpression))

  (ExponentOperator "^")

  (PipeExpression PostfixExpression
                  (PipeExpression PipeOperator UnaryExpression))

  (PipeOperator "|>")

  (UnaryExpression PostfixExpression
                   (PrefixOperator UnaryExpression))

  (PrefixOperator "+" "-")

  (PostfixExpression primaryExpression
                     (PostfixExpression PostfixOperator))

  (PostfixOperator memberExpression
                   callExpression
                   indexExpression)
  )
