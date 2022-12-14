#lang racket
(require redex)

(provide Flux)

(define-language Flux

  ;; Packages
  ;; --------
  (PackageClause ("package" Identifier)
                 (Attributes "package" Identifier))
  (File StatementList
        (PackageClause StatementList)
        (ImportList StatementList)
        (PackageClause ImportList StatementList))
  (ImportList (ImportDeclaration ...))
  (ImportDeclaration ("import" StringLit)
                     ("import" Identifier StringLit)
                     (Attributes "import" StringLit)
                     (Attributes "import" Identifier StringLit))

  (Attributes '() (Attribute ...))
  (Attribute ("@" Identifier AttributeParameters))
  (AttributeParameters '() ( "(" AttributeParameterList ")" ))
  (AttributeParameterList (AttributeParameter ...))
  (AttributeParameter PrimaryExpression)
  
  ;; Blocks
  ;; ------
  (Block 𝒰
         PackageBlock
         FileBlock
         FunctionLitBlock
         ("{" StatementList "}"))

  ;; Statements
  ;; ----------
  (StatementList (Statement ...))
  (Statement OptionAssignment
             BuiltinStatement
             VariableAssignment
             ReturnStatement
             ExpressionStatement)

  (OptionAssignment ("option" OptionPath "=" Expression))
  (OptionPath Identifier (Identifier "." Identifier))

  (BuiltinStatement ("builtin" Identifier ":" TypeExpression))
  (TypeExpression MonoType (MonoType "where" Constraints))
  (MonoType Tvar BasicType ArrayType StreamType VectorType RecordType FunctionType)
  (Tvar "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z")
  (BasicType "int" "uint" "float" "string" "bool" "time" "duration") ; TODO "bytes" and "regex"
  (ArrayType ("[" MonoType "]"))
  (StreamType ("stream" "[" MonoType "]"))
  (VectorType ("vector" "[" MonoType "]"))
  (RecordType ("{" "}")
              ("{" RecordTypeProperties "}")
              ("{" Tvar "with" RecordTypeProperties "}"))
  (FunctionType ("(" ")" "=>" MonoType)
                ("(" FunctionTypeParameters ")" "=>" MonoType))
  (RecordTypeProperties (RecordTypeProperty RecordTypeProperty ...))
  (RecordTypeProperty (Label ":" MonoType))
  (Label Identifier StringLit)
  (FunctionTypeParameters (FunctionTypeParameter FunctionTypeParameter ...))
  (FunctionTypeParameter (Identifier ":" MonoType)
                         ("<-" Identifier ":" MonoType)
                         ("?" Identifier ":" MonoType))
  (Constraints (Constraint Constraint ...))
  (Constraint (Tvar ":" Kinds))
  ;; Kinds       = identifier { "+" identifier } .
  ;; TODO To "+" or not to "+"? That is the question.
  (Kinds (Identifier AdditionalIdentifier ...))
  (AdditionalIdentifier ("+" Identifier))
  (VariableAssignment (Identifier "=" Expression))

  (ReturnStatement ("return" Expression))

  (ExpressionStatement Expression)

  (PrimaryExpression Identifier
                     Literal
                     ("(" Expression ")"))

  ;; TODO decide how to handle this
  ;; identifier (letter { letter | unicode_digit } .
  (Identifier variable-not-otherwise-mentioned)

  (decimalDigit "0" "1" "2" "3" "4" "5" "6" "7" "8" "9")

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

  (FloatLit (decimals ".") (decimals "." decimals) ("." decimals))
  (decimals (decimalDigit decimalDigit ...))

  (StringLit string)

  ;; TODO maybe?
  ;; (regexLit)

  (DurationLit (durationMagnitude DurationUnit))
  (durationMagnitude integer)
  (DurationUnit "y" "mo" "w" "d" "h" "m" "s" "ms" "us" "μs" "ns")

  ;; TODO review all of these
  (DateTimeLit date (date "T" time))
  (date (year "-" month "-" day))
  (year (decimalDigit decimalDigit decimalDigit decimalDigit))
  (month (decimalDigit decimalDigit))
  (day (decimalDigit decimalDigit))
  (time (hour ":" minute ":" second)
        (hour ":" minute ":" second timeOffset)
        (hour ":" minute ":" second fractionalSecond timeOffset))
  (hour (decimalDigit decimalDigit))
  (minute (decimalDigit decimalDigit))
  (second (decimalDigit decimalDigit))
  (fractionalSecond ("." (decimalDigit ...)))
  (timeOffset "Z" ("+" hour ":" minute) ("-" hour ":" minute))

  (RecordLit ("{" RecordBody "}"))
  (RecordBody WithProperties PropertyList)
  (WithProperties (Identifier "with" PropertyList))
  (PropertyList (Property ...))
  (Property Identifier
            (Identifier ":" Expression)
            (StringLit ":" Expression))

  (ArrayLit ("[" ExpressionList "]"))
  (ExpressionList (Expression ...))

  (DictLit EmptyDict ("[" AssociativeList "]"))
  (EmptyDict ("[" ":" "]"))
  (AssociativeList (Association ...)) ; TODO something fishy...
  (Association (Expression ":" Expression))

  (FunctionLit (FunctionParameters "=>" FunctionBody))

  (FunctionParameters EmptyParameterList
                      ("(" ParameterList ")")
                      ("(" ParameterList "," ")")) ; spec means to allow trailing comma?
  (EmptyParameterList "()")

  (ParameterList (Parameter Parameter ...))

  (Parameter Identifier (Identifier "=" Expression))

  (FunctionBody Expression Block)

  (CallExpression ( "(" PropertyList ")"))

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
  (PostfixOperator MemberExpression CallExpression IndexExpression)

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

  (ComparisonExpression AdditiveExpression
                        (ComparisonExpression ComparisonOperator AdditiveExpression))

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
  ;;
  )

(module+ test

  (test-match Flux Identifier (term deadfeed))
  (test-match Flux PackageClause (term ("package" foo)))
  (test-match Flux Statement (term (x "=" 1)))
  (define st-list (term ((x "=" 1) x)))
  (test-match Flux StatementList st-list)
  (test-match Flux File (term (st-list)))
  (test-match Flux Block (term 𝒰))

  (define attr-param (term ("(" "2022.1" ")")))
  (test-match Flux AttributeParameter attr-param)
  (test-match Flux AttributeParameterList attr-param)
  (test-match Flux AttributeParameterList (term (,attr-param ,attr-param)))
  (define attr-params (term ( "(" (attr-param) ")")))
  (test-match Flux AttributeParameters attr-params)
  (test-match Flux Attribute (term ("@" edition ,attr-params)))
  
  ;; STATEMENTS
  ;; ----------
  (test-match Flux StatementList (term ("return" foo)))
  (test-match Flux VariableAssignment (term (foo "=" 1)))
  ;; function definition `sup = () => 1`
  (test-match Flux VariableAssignment (term (sup "=" ( "()" "=>" 1))))
  ;; function definition `add = (a, b) => a + b`
  (test-match Flux VariableAssignment (term ( add "=" (("(" (a b) ")") "=>" (a "+" b)))))

  (test-match Flux FunctionParameters (term ("(" (foo) ")")))

  (define array-int (term ("vector" "[" "int" "]")))
  (test-match Flux BuiltinStatement (term ("builtin" foo ":" "int") ))
  (test-match Flux BuiltinStatement (term ("builtin" foo ":" ,array-int) ))
  (test-match Flux BuiltinStatement (term ("builtin" foo ":" ,array-int) ))

  ;; (r: T) => bool
  (define inner-func-type (term ("(" ((r ":" "T")) ")" "=>" "bool")))
  (test-match Flux FunctionType inner-func-type)
  ;; (<-tables: [T], fn: (r: T) => bool)
  (define stream-array-t (term ("stream" "[" "T" "]")))
  (define func-ty-params (term (("<-" tables ":" ,stream-array-t) (fn ":" ,inner-func-type))))
  (test-match Flux FunctionTypeParameters func-ty-params)
  ;; TODO `stream[T]`? See https://github.com/influxdata/flux/pull/5206
  ;; builtin filter : (<-tables: [T], fn: (r: T) => bool) => [T]
  (test-match Flux BuiltinStatement (term ("builtin" filter ":" ("(" ,func-ty-params ")" "=>" ,stream-array-t))))

  (test-match Flux TypeExpression (term "time"))
  (test-match Flux TypeExpression (term ("T" "where" (("T" ":" (fooo))))))
  (test-match Flux Tvar (term "B"))
  (test-match Flux Constraint (term ("T" ":" (fooo))))

  ;; LITERALS
  ;; --------
  (test-match Flux decimals (term ("0")))
  (test-match Flux decimals (term ("0" "1")))
  (test-match Flux FloatLit (term (("0") ".")))

  (test-match Flux DictLit (term ("[" (["foo" ":" 1]) "]")))
  (define assoc (term ("foo" ":" 1)))
  (test-match Flux Association assoc)
  (define assoc-list (term (["foo" ":" 1] ["bar" ":" 2]))) ; ???
  (test-match Flux AssociativeList assoc-list)
  (test-match Flux DictLit (term ("[" ,assoc-list "]")))

  (test-match Flux ArrayLit (term ("[" (1) "]")))
  (test-match Flux ArrayLit (term ("[" (1 2 3) "]")))
  ;; FIXME this needs to error somewhere
  (test-match Flux ArrayLit (term ("[" (1 2 "sup") "]")))
  (test-match Flux RecordLit (term ( "{" ((sup ":" 1)) "}")))
  (test-match Flux RecordLit (term ( "{" () "}")))
  (test-match Flux Property (term (sup ":" 1)))
  (test-match Flux PropertyList '())
  (test-match Flux FunctionLit (term ("()" "=>" 1)))

  (define fn-params (term ("(" (a b) ")")))
  (test-match Flux FunctionParameters fn-params)
  ;; (a, b) => 1 ;; UNUSED Params?
  (test-match Flux FunctionLit (term ( ,fn-params "=>" 1)))
  (test-match Flux Parameter (term sup))
  (test-match Flux Parameter (term (sup "=" 1)))
  (test-match Flux ParameterList (term ((sup "=" 1))))
  (test-match Flux ParameterList (term (foo bar)))
  (test-match Flux ParameterList (term ((foo "=" baz) (bar "=" true))))

  ;; TIME
  ;; ----
  (define eleven (term ("1" "1")))
  (define y2k (term ("2" "0" "0" "0")))
  (define test_time (term (,eleven ":" ,eleven ":"  ,eleven "Z")))
  (define test_time_weird (term (,eleven ":" ("8" "8") ":"  ,eleven "Z")))
  (define test_frac_s (term ("." ("1"))))
  (test-match Flux date (term (,y2k "-" ,eleven "-" ,eleven)))
  (test-match Flux year y2k)
  (test-match Flux month eleven)
  (test-match Flux day eleven)
  (test-match Flux time test_time)
  (test-match Flux time test_time_weird)
  ;; (test-match Flux time (term (,test_time ,test_frac_s)))
  ;; (test-match Flux time (term (,test_time "Z")))
  ;; (test-match Flux time (term (,test_time ,timeOffset)))
  (test-match Flux hour eleven)
  (test-match Flux minute eleven)
  (test-match Flux second eleven)
  (test-match Flux fractionalSecond test_frac_s)
  (test-match Flux timeOffset "Z")
  (test-match Flux timeOffset (term ("+" ,eleven ":" ,eleven)))
  (test-match Flux timeOffset (term ("-" ,eleven ":" ,eleven)))

  ;; Expressions
  ;; -----------
  (test-match Flux PrimaryExpression (term (1 "w")))
  (test-match Flux PrimaryExpression (term ("(" (1 "w") ")")))
  (define proplist (term ((sup ":" 1))))
  (test-match Flux CallExpression (term ( "(" ,proplist ")")))
  (test-match Flux AdditiveExpression (term (a "+" b)))
  (test-match Flux ConditionalExpression (term ("if" a "then" b "else" c)))

  ;; FIXME bug
  (test-match Flux Expression (term (a "+" b)))

  ;;
  )
