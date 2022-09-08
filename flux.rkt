#lang racket
(require redex)

(provide Flux)

(define-language Flux

  (packageClause ("package" identifier))

  ;; File = [ PackageClause ] [ ImportList ] StatementList .
  (file (packageClause importList statementList))

  ;; ImportList = { ImportDeclaration } .
  (importList (importDeclaration ...))

  (type "null"
        Boolean
        string

        Time
        duration

        array
        record
        dictionary
        function
        generator

        ;; regex
        ;; bytes
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

  ;;   In addition to explicit blocks in the source code, there are implicit blocks:
  ;;
  ;;     The universe block encompasses all Flux source text.
  ;;     Each package has a package block containing all Flux source text for that package.
  ;;     Each file has a file block containing all Flux source text in that file.
  ;;     Each function literal has its own function block even if not explicitly declared.
  ;;
  ;; Blocks nest and influence scoping.
  ;; https://docs.influxdata.com/flux/v0.x/spec/blocks/
  (block ("{" statementList "}" ))

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

  (identifier variable-not-otherwise-mentioned)

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
  ;; (pipeReceiveLit)

  ;; TODO
  ;; (recordLit)

  ;; TODO
  ;; (arrayLit)

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
  (parameter identifier)

  ;; FunctionBody       = Expression | Block .
  (functionBody expression)

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

  ;; identifier (letter { letter | unicode_digit } .
  ;; (identifier (letter (letter ))

  (operators
   "+" "==" "!=" "(" ")" "=>" "-" "<" "!~" "[" "]" "^"
   "*" ">" "=~" "{" "}" "/" "<=" "=" "," ":" "%" ">=" "<-" "." "|>" )

  ;; Operator precedence
  ;; -------------------

  ;; Expression               = ConditionalExpression .
  (expression ConditionalExpression)
  ;; ConditionalExpression    = LogicalExpression
  ;;                           | "if" Expression "then" Expression "else" Expression .
  (ConditionalExpression ("if" expression "then" expression "else" expression))
  ;; LogicalExpression        = UnaryLogicalExpression
  ;;                           | LogicalExpression LogicalOperator UnaryLogicalExpression .
  (LogicalExpression UnaryLogicalExpression
                     (LogicalExpression LogicalOperator UnaryLogicalExpression))
  ;; LogicalOperator          = "and" | "or" .
  (logicalOperator "and" "or")
  ;; UnaryLogicalExpression   = ComparisonExpression
  ;;                           | UnaryLogicalOperator UnaryLogicalExpression .
  (UnaryLogicalExpression Comparisonexpression
                          (UnaryLogicalOperator UnaryLogicalExpression))
  ;; UnaryLogicalOperator     = "not" | "exists" .
  (UnaryLogicalOperator "not" "exists")
  ;; ComparisonExpression     = MultiplicativeExpression
  ;;                           | ComparisonExpression ComparisonOperator MultiplicativeExpression .
  (ComparisonExpression MultiplicativeExpression
                        (ComparisonExpression ComparisonOperator MultiplicativeExpression))
  ;; ComparisonOperator       = "==" | "!=" | "<" | "<=" | ">" | ">=" | "=~" | "!~" .
  ;; (comparisonOperator)
  ;; ;; AdditiveExpression       = MultiplicativeExpression
  ;; ;;                           | AdditiveExpression AdditiveOperator MultiplicativeExpression .
  ;; (additiveExpression)
  ;; ;; AdditiveOperator         = "+" | "-" .
  ;; (additiveOperator)
  ;; ;; MultiplicativeExpression = ExponentExpression
  ;; ;;                           | ExponentExpression ExponentOperator MultiplicativeExpression .
  ;; ;;                           | ExponentExpression MultiplicativeOperator MultiplicativeExpression .
  ;; (multiplicativeExpression)
  ;; ;; MultiplicativeOperator   = "*" | "/" | "%" .
  ;; (multiplicativeOperator)
  ;; ;; ExponentExpression       = PipeExpression
  ;; ;;                           | ExponentExpression ExponentOperator PipeExpression .
  ;; (exponentExpression)
  ;; ;; ExponentOperator         = "^" .
  ;; (exponentOperator)
  ;; ;; PipeExpression           = PostfixExpression
  ;; ;;                           | PipeExpression PipeOperator UnaryExpression .
  ;; (pipeExpression)
  ;; ;; PipeOperator             = "|>" .
  ;; (pipeOperator)
  ;; ;; UnaryExpression          = PostfixExpression
  ;; ;;                           | PrefixOperator UnaryExpression .
  ;; (unaryExpression)
  ;; ;; PrefixOperator           = "+" | "-" .
  ;; (prefixOperator)
  ;; ;; PostfixExpression        = PrimaryExpression
  ;; ;;                           | PostfixExpression PostfixOperator .
  ;; (postfixExpression)
  ;; ;; PostfixOperator          = MemberExpression
  ;; ;;                           | CallExpression
  ;; ;;                           | IndexExpression .
  ;; (postfixOperator)

  )
