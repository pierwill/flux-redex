#lang racket
(require redex
         "flux.rkt"
         )

(module+ test

  (redex-match Flux primaryExpression
               (term (1 "w")))

  (redex-match Flux primaryExpression
               (term
                ("(" (1 "w") ")" )))
  
  (redex-match Flux variableAssignment
               (term
                (foo "=" 1)))

  (redex-match Flux functionLit
               (term ("()" "=>" 1)))

  ;; function definition
  (redex-match Flux variableAssignment
               (term (sup
                      "="
                      ( "()" "=>" 1))))

  ;; ;; function definition
  ;; (redex-match Flux callExpression
  ;;              (term (sup "(" a ")" )))

  )
