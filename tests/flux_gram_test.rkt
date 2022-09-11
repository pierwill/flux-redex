#lang racket
(require redex
         "../flux.rkt"
         )

(module+ test

  (test-match Flux Identifier
              (term deadfeed))

  ;; Packages
  ;; --------
  (test-match Flux PackageClause
              (term ("package" foo)))

  ;; TODO
  ;; (test-match Flux File
  ;;             (term ()))

  ;; Blocks
  ;; ------
  (test-match Flux Block
              (term 𝒰))

  ;; Statements
  ;; ----------
  (test-match Flux StatementList
              (term ("return" foo)))

  (test-match Flux VariableAssignment
              (term (foo "=" 1)))

  ;; function definition
  ;; sup = () => 1
  (test-match Flux VariableAssignment
              (term (sup
                     "="
                     ( "()" "=>" 1))
                    ))

  ;; TODO
  ;; add = (a, b) => a + b
  (test-match Flux VariableAssignment
              (term
               (; Identifier
                add
                "="
                (; FunctionList
                 ("(" (a b) ")") ; ParameterList
                 "=>"
                 ;; FIXME once AdditiveExpression is fixed
                 ;; (a "+" b)                      ; FunctionBody
                 a
                 )
                )
               ))

  (test-match Flux FunctionParameters
              (term ("(" (foo) ")")
                    ))

  (test-match Flux BuiltinStatement
              (term ("builtin" foo ":" "int")
                    ))

  (test-match Flux BuiltinStatement
              (term ("builtin" foo ":" ("[" "int" "]"))
                    ))

  (test-match Flux BuiltinStatement
              (term ("builtin" foo ":" ("["
                                        "int"
                                        "]"))
                    ))

  (test-match Flux TypeExpression
              (term "time"))

  (test-match Flux TypeExpression
              (term ("T" "where" (("T" ":" (fooo))))
                    ))

  (test-match Flux Tvar
              (term "B"))

  (test-match Flux Constraint
              (term ("T" ":" (fooo))
                    ))

  ;; Literals
  ;; --------
  (test-match Flux decimals (term ("0")))
  (test-match Flux decimals (term ("0" "1")))
  (test-match Flux FloatLit (term (("0") ".")))

  (test-match Flux RecordLit
              (term (
                     "{"
                     ((sup ":" 1))
                     "}"
                     )
                    ))

  (test-match Flux Property
              (term (sup ":" 1)))

  (test-match Flux PropertyList
              '())

  (test-match Flux FunctionLit
              (term ("()" "=>" 1)))

  (test-match Flux FunctionLit
              (term
               (
                ("(" (a b) ")")     ; FunctionParameters
                "=>"
                1                 ; FunctionBody
                )
               ))

  (test-match Flux FunctionParameters
              (term ("(" (foo bar) ")")
                    ))

  (test-match Flux Parameter
              (term sup))

  (test-match Flux Parameter
              (term (sup "=" 1)))

  (test-match Flux ParameterList
              (term ((sup "=" 1))
                    ))

  (test-match Flux ParameterList
              (term (foo bar)
                    ))

  (test-match Flux ParameterList
              (term ((foo "=" baz) (bar "=" true))
                    ))

  ;; TIME
  ;; ----
  (define eleven (term ("1" "1")))
  (define y2k (term ("2" "0" "0" "0")))
  (define test_time (term (,eleven ":" ,eleven ":" ,eleven)))
  (define test_frac_s (term ("." ("1"))))

  (test-match Flux date (term (,y2k "-" ,eleven "-" ,eleven)))
  (test-match Flux year y2k)
  (test-match Flux month eleven)
  (test-match Flux day eleven)
  (test-match Flux time test_time)
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

  (test-match Flux PrimaryExpression
              (term (1 "w")))

  (test-match Flux PrimaryExpression
              (term
               ("(" (1 "w") ")" )
               ))

  (test-match Flux CallExpression
              (term (
                     "("
                     ((sup ":" 1)) ; PropertyList
                     ")"
                     )
                    ))

  (test-match Flux AdditiveExpression
              (term (a "+" b)
                    ))

  (test-match Flux ConditionalExpression
              (term ("if" a "then" b "else" c)
                    ))
  ;; FIXME bug
  ;; (test-match Flux Expression
  ;;              (term (a "+" b)
  ;;                    ))

  ;; TODO
  ;; builtin filter : (<-tables: [T], fn: (r: T) => bool) => [T]

  ;; TODO constraints. This should fail:
  ;;     add = (a, b) => a + b
  ;;     add(a: {}, b: {})
  ;; See spec example.

  ;; 
  )
