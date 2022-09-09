#lang racket
(require redex
         "flux.rkt"
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
  (test-match Flux VariableAssignment
              (term (sup
                     "="
                     ( "()" "=>" 1))
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
              (term ("T1" "where" (("T1" ":" fooo)))
                    ))

  (test-match Flux Tvar
              (term "sup"))

  (test-match Flux Constraint
              (term ("T1" ":" fooo)
                    ))

  ;; Literals
  ;; --------

  (test-match Flux RecordLit
              (term (
                     "{"
                     ((sup ":" 1))
                     "}"
                     )
                    ))

  (test-match Flux Property
              (term (sup ":" 1)))

  (test-match Flux FunctionLit
              (term ("()" "=>" 1)))

  (test-match Flux FunctionParameters
              (term ("(" (foo bar) ")")
                    ))

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
  ;; TODO bug?
  ;; (test-match Flux Expression
  ;;              (term (a "+" b)
  ;;                    ))

  ;; TODO
  ;; builtin filter : (<-tables: [T], fn: (r: T) => bool) => [T]

  ;; TODO
  ;; add = (a, b) => a + b
  (redex-match Flux FunctionLit
               (term
                (
                 ("(" (a b) ")")     ; FunctionParameters
                 "=>"
                 1                 ; FunctionBody
                 )
               ))

  ;; TODO constraints. This should fail:
  ;;     add(a: {}, b: {})
  ;; See spec example.
  )
