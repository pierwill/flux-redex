#lang racket
(require redex
         "flux.rkt"
         )

(module+ test

  (redex-match Flux expression
               (term (1 "w")))

  (redex-match Flux expression
               (term
                ("(" (1 "w") ")" ))
                )

  (redex-match Flux identifier (term foo))
  
  (redex-match Flux variableAssignment
               (term
                (foo "=" 1)))

  (redex-match Flux functionLit
               (term (
                      "()"
                      "=>"
                      1
                      )))
  )
