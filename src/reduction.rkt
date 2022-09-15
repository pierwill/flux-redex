#lang racket
(require redex
         "grammar.rkt"
         )

(define-extended-language Flux-eval Flux

  ;; (MachineState ::= (Store E))
  ;; (Store ((VarName Val) ... ))

  (Val ::= IntVal)

  (IntVal ::= IntLit)

  (E ::= hole
     (E "+" Expression)
     (Val "+" E)
     (E "==" Expression)
     (Val "==" E)
     )

  ;;
  )

(provide flux-red)

(define flux-red
  (reduction-relation
   Flux-eval

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

   (--> (in-hole E (Val_1 "==" Val_2))
        (in-hole E ,(equal? (term Val_1) (term Val_2)))
        "equal")

   (--> (in-hole E (Val_1 "!=" Val_2))
        (in-hole E ,(not (equal? (term Val_1) (term Val_2))))
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

   (--> (in-hole E (integer_1 "+" integer_2))
        (in-hole E  ,(+ (term integer_1) (term integer_2)))
        "add")

   ;; (--> (in-hole E (IntLit_1 "+" IntLit_2))
   ;;      (in-hole E  ,(+ (term IntLit_1) (term IntLit_2)))
   ;;      "add-int")

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

  (test-->> flux-red (term (4 "==" 2)) (term #f))
  (test-->> flux-red (term (4 "!=" 2)) (term #t))
  (test-->> flux-red (term (6 "==" (4 "+" 2))) (term #t))
  (test-->> flux-red (term (1 "+" (4 "+" 2))) (term 7))
  (test-->> flux-red (term (3 "^" 2)) (term 9))
  (test-->> flux-red (term (3 "*" 2)) (term 6))
  (test-->> flux-red (term ("exists" "null")) (term #f))
  (test-->> flux-red (term ("exists" "hello")) (term #t))
  ;; (test-->> flux-red (term ("if" true "then" false "else" true)) (term false))
  ;; (test-->> flux-red (term (true "and" false)) (term false))
  ;; (test-->> flux-red (term (true "or" false)) (term true))

  ;; TODO
  ;; (test-->> flux-red (term (1 ">" (2 "^" 2))) (term false))

  ;; FIXME #f vs false
  ;; (test-->> flux-red (term (32 "!=" 31)) (term true))

  ;; FIXME #f vs false
  ;; (test-->> flux-red (term (true "==" false)) (term false))

  ;;
  )

;; (traces flux-red (term (6 "==" (4 "+" 2))))
;; (traces flux-red (term ((4 "+" 2) "==" 7)))
