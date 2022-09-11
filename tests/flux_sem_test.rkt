#lang racket
(require redex
         "../src/grammar.rkt"
         "../src/reduction.rkt"
         )

(module+ test

  ;; SEMANTICS
  ;; =========
  
  (test-->>
   flux-red
   (term (3 "^" 2))
   (term 9))

  (test-->>
   flux-red
   (term (3 "*" 2))
   (term 6))

  ;; (test-->>
  ;;  flux-red
  ;;  (term (4 "^" (2 "*" 2)))
  ;;  (term 256))
  
  (test-->>
   flux-red
   (term (true "and" false))
   (term false))

  (test-->>
   flux-red
   (term (true "or" false))
   (term true))

  ;; (test-->>
  ;; flux-red
  ;; (term (true "==" false))
  ;; (term false))

  ;; (apply-reduction-relation flux-red (term (9 "/" 4)))
  ;; (apply-reduction-relation flux-red (term (9 "==" 9)))
  ;; (apply-reduction-relation flux-red (term (sup "!=" 9)))
  ;; (apply-reduction-relation flux-red (term (9 ">=" 4)))
  ;; (apply-reduction-relation flux-red (term (4 "^" 2)))

  ;; end test module
  )
