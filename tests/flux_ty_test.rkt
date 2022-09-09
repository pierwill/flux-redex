#lang racket
(require redex
         "../flux-ty.rkt"
         )

(module+ test


(test-match Flux-ty BuiltinStatement
              (term ("builtin" foo ":" "int")
                    ))

  (test-match Flux-ty BuiltinStatement
              (term ("builtin" foo ":" ("[" "int" "]"))
                    ))

  (test-match Flux-ty BuiltinStatement
              (term ("builtin" foo ":" ("["
                                        "int"
                                        "]"))
                    ))

  (test-match Flux-ty TypeExpression
              (term "time"))

  (test-match Flux-ty TypeExpression
              (term ("T1" "where" (("T1" ":" fooo)))
                    ))

  (test-match Flux-ty Tvar
              (term "sup"))

  (test-match Flux-ty Constraint
              (term ("T1" ":" fooo)
                    ))

)
