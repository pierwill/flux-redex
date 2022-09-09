#lang racket
(require redex
         "flux.rkt"
         )

(module+ test

  (test-match Flux Block
               (term 𝒰))

  (test-match Flux primaryExpression
              (term (1 "w")))

  (test-match Flux primaryExpression
               (term
                ("(" (1 "w") ")" )
                ))

  (test-match Flux variableAssignment
               (term (foo "=" 1)))

  (test-match Flux functionLit
               (term ("()" "=>" 1)))

  ;; function definition
  (test-match Flux variableAssignment
               (term (sup
                      "="
                      ( "()" "=>" 1))
                     ))

  (test-match Flux property
               (term (sup ":" 1)))

  (test-match Flux callExpression
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

  (test-match Flux builtinStatement
               (term ("builtin" foo ":" "int")
                     ))

  (test-match Flux builtinStatement
               (term ("builtin" foo ":" ("[" "int" "]"))
                     ))

  (test-match Flux builtinStatement
               (term ("builtin" foo ":" ("["
                                            "int"
                                            "]"))
                     ))

  ;; TODO
  ;; builtin filter : (<-tables: [T], fn: (r: T) => bool) => [T]
  )
