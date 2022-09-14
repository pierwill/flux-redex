#lang racket
(require redex
         "grammar.rkt"
         )

(provide flux-red)

(define flux-red
  (reduction-relation
   Flux

   (--> ("if" Expression_1 "then" Expression_2 "else" Expression_3)
        ,(if (term Expression_1) (term Expression_2) (term Expression_3))
        "if-then-else")

   (--> (Expression_1 "and" Expression_2)
        ,(and (term Expression_1) (term Expression_2))
        "and")

   (--> (Expression_1 "or" Expression_2)
        ,(or (term Expression_1) (term Expression_2))
        "or")

   (--> ("not" Expression_1)
        ,(not (term Expression_1))
        "not")

   (--> ("exists" Expression_1)
        ,(if (equal? (term Expression_1) (term "null")) #f #t)
        "exists")

   (--> (Expression_1 "==" Expression_2)
        ,(equal? (term Expression_1) (term Expression_2))
        "equal")

   (--> (Expression_1 "!=" Expression_2)
        ,(not (equal? (term Expression_1) (term Expression_2)))
        "not-equal")

   (--> (Expression_1 "<" Expression_2)
        ,(< (term Expression_1) (term Expression_2))
        "less than")

   (--> (Expression_1 ">" Expression_2)
        ,(> (term Expression_1) (term Expression_2))
        "greater than")

   (--> (Expression_1 "<=" Expression_2)
        ,(<= (term Expression_1) (term Expression_2))
        "less than or eq")

   (--> (Expression_1 ">=" Expression_2)
        ,(>= (term Expression_1) (term Expression_2))
        "greater than or eq")

   (--> (Expression_1 "+" Expression_2)
        ,(+ (term Expression_1) (term Expression_2))
        "add")

   (--> (Expression_1 "-" Expression_2)
        ,(- (term Expression_1) (term Expression_2))
        "subtract")

   (--> (Expression_1 "*" Expression_2)
        ,(* (term Expression_1) (term Expression_2))
        "multiply")

   (--> (Expression_1 "/" Expression_2)
        ,(/ (term Expression_1) (term Expression_2))
        "divide")

   (--> (Expression_1 "^" Expression_2)
        ,(expt (term Expression_1) (term Expression_2))
        "exponentiation")

   ;; TODO (PipeOperator "|>")

   ;; TODO do these unary prefix operators only apply to durations?
   ;; (--> ("+" Expression)
   ;;      ,()
   ;;      "?")
   ;; (--> ("-" Expression)
   ;;      ,()
   ;;      "??")

   ;; TODO (PrefixOperator "+" "-")

   ;; TODO "=~"
   ;; TODO "!~"
   ;; TODO %

   ;;
   ))

(module+ test

  (test-->> flux-red (term (3 "^" 2)) (term 9))

  (test-->> flux-red (term (3 "*" 2)) (term 6))

  (test-->> flux-red (term ("if" true "then" false "else" true)) (term false))

  (test-->> flux-red (term (true "and" false)) (term false))

  (test-->> flux-red (term (true "or" false)) (term true))

  (test-->> flux-red (term ("exists" "null")) (term #f))

  (test-->> flux-red (term ("exists" "hello")) (term #t))

  ;; TODO
  ;; (test-->> flux-red (term (1 ">" (2 "^" 2))) (term false))

  ;; FIXME #f vs false
  ;; (test-->>
  ;;  flux-red
  ;;  (term (32 "!=" 31))
  ;;  (term true))

  ;; FIXME #f vs false
  ;; (test-->>
  ;; flux-red
  ;; (term (true "==" false))
  ;; (term false))

  )

;; (apply-reduction-relation flux-red (term (9 "/" 4)))
;; (apply-reduction-relation flux-red (term (9 "==" 9)))
;; (apply-reduction-relation flux-red (term (sup "!=" 9)))
;; (apply-reduction-relation flux-red (term (9 ">=" 4)))
;; (apply-reduction-relation flux-red (term (4 "^" 2)))
