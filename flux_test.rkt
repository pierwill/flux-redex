#lang racket
(require redex
         "flux.rkt"
         )

(module+ test

  (test-match Flux Block
              (term 𝒰))

  (test-match Flux PrimaryExpression
              (term (1 "w")))

  (test-match Flux PrimaryExpression
              (term
               ("(" (1 "w") ")" )
               ))

  (test-match Flux VariableAssignment
              (term (foo "=" 1)))

  (test-match Flux FunctionLit
              (term ("()" "=>" 1)))

  ;; function definition
  (test-match Flux VariableAssignment
              (term (sup
                     "="
                     ( "()" "=>" 1))
                    ))

  (test-match Flux Property
              (term (sup ":" 1)))

  (test-match Flux CallExpression
              (term ("(" ((sup ":" 1)) ")")
                    ))

  (test-match Flux Tvar
              (term "sup"))

  (test-match Flux Identifier
              (term deadfeed))

  (test-match Flux Constraint
              (term ("T1" ":" fooo)
                    ))

  (test-match Flux TypeExpression
              (term "time"))

  (test-match Flux TypeExpression
              (term ("T1" "where" (("T1" ":" fooo)))
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

  ;; TODO
  ;; builtin filter : (<-tables: [T], fn: (r: T) => bool) => [T]
  )
