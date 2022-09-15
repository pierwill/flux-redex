#lang racket
(require redex
         "grammar.rkt"
         )

(define-extended-language Flux-eval Flux

  (Val ::= IntVal
       StringVal
       BoolVal
       "null"
       ;; temporary hack
       ;; define these in a Store
       ;; (term #t)
       ;; (term #f)
       )

  (IntVal ::= IntLit)
  (StringVal ::= StringLit)
  (BoolVal ::= #f #t)

  (E ::= hole
     (E "+" Expression)
     (Val "+" E)

     (E "-" Expression)
     (Val "-" E)

     (E "*" Expression)
     (Val "*" E)

     (E "/" Expression)
     (Val "/" E)

     (E "==" Expression)
     (Val "==" E)

     (E "and" Expression)
     (Val "and" E)

     (E "or" Expression)
     (Val "or" E)

     ("not" E)

     ("exists" E)
     )

  ;;
  )

(provide flux-red)

(define flux-red
  (reduction-relation
   Flux-eval

   ;; TODO
   (--> ("if" Expression_1 "then" Expression_2 "else" Expression_3)
        ,(if (term Expression_1) (term Expression_2) (term Expression_3))
        "if-then-else")

   (--> (in-hole E (Val_1 "and" Val_2))
        (in-hole E ,(and (term Val_1) (term Val_2)))
        "and")

   (--> (in-hole E (Val_1 "or" Val_2))
        (in-hole E ,(or (term Val_1) (term Val_2)))
        "or")

   (--> (in-hole E ("not" Val_1))
        (in-hole E ,(not (term Val_1)))
        "not")

   (--> (in-hole E ("exists" Val))
        (in-hole E ,(if (equal? (term Val) (term "null")) #f #t))
        "exists")

   (--> (in-hole E (Val_1 "==" Val_2))
        (in-hole E ,(equal? (term Val_1) (term Val_2)))
        "equal")

   (--> (in-hole E (Val_1 "!=" Val_2))
        (in-hole E ,(not (equal? (term Val_1) (term Val_2))))
        "not-equal")

   ;; TODO
   (--> (Expression_1 "<" Expression_2)
        ,(< (term Expression_1) (term Expression_2))
        "less than")

   ;; TODO
   (--> (Expression_1 ">" Expression_2)
        ,(> (term Expression_1) (term Expression_2))
        "greater than")

   ;; TODO
   (--> (Expression_1 "<=" Expression_2)
        ,(<= (term Expression_1) (term Expression_2))
        "less than or eq")

   ;; TODO
   (--> (Expression_1 ">=" Expression_2)
        ,(>= (term Expression_1) (term Expression_2))
        "greater than or eq")

   (--> (in-hole E (integer_1 "+" integer_2))
        (in-hole E ,(+ (term integer_1) (term integer_2)))
        "add")

   ;; (--> (in-hole E (IntLit_1 "+" IntLit_2))
   ;;      (in-hole E  ,(+ (term IntLit_1) (term IntLit_2)))
   ;;      "add-int")

   (--> (in-hole E (Val_1 "-" Val_2))
        (in-hole E ,(- (term Val_1) (term Val_2)))
        "subtract")

   (--> (in-hole E (Val_1 "*" Val_2))
        (in-hole E ,(* (term Val_1) (term Val_2)))
        "multiply")

   (--> (in-hole E (Val_1 "/" Val_2))
        (in-hole E ,(/ (term Val_1) (term Val_2)))
        "divide")

   (--> (in-hole E (Val_1 "^" Val_2))
        (in-hole E ,(expt (term Val_1) (term Val_2)))
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
  (test-->> flux-red (term (1 "-" 1)) (term 0))
  (test-->> flux-red (term (9 "-" (4 "-" 2))) (term 7))
  (test-->> flux-red (term (1 "+" (4 "+" 2))) (term 7))
  (test-->> flux-red (term ((3 "+" 2) "+" (3 "+" 2))) (term 10)) ; 🖜 () + () works here
  (test-->> flux-red (term (3 "^" 2)) (term 9))
  (test-->> flux-red (term (3 "*" 2)) (term 6))
  (test-->> flux-red (term (3 "*" (3 "*" 4))) (term 36))
  (test-->> flux-red (term (12 "/" 4)) (term 3))
  (test-->> flux-red (term (12 "/" (2 "+" 2))) (term 3))
  (test-->> flux-red (term (6 "==" (4 "+" 2))) (term #t))
  (test-->> flux-red (term ((4 "+" 2) "==" 7)) (term #f))
  (test-->> flux-red (term ("exists" "null")) (term #f))
  (test-->> flux-red (term ("exists" "hello")) (term #t))
  (test-->> flux-red (term ("exists" ("exists" "hello"))) (term #t))
  (test-->> flux-red (term ("exists" ("exists" "null"))) (term #t))
  (test-->> flux-red (term (#t "and" #f)) (term #f))
  (test-->> flux-red (term (#t "and" #t)) (term #t))
  (test-->> flux-red (term (#t "and" (#t "and" #f))) (term #f))
  (test-->> flux-red (term (#t "or" #f)) (term #t))
  (test-->> flux-red (term (#t "or" #t)) (term #t))
  (test-->> flux-red (term (#f "or" (#t "or" #f))) (term #t))
  (test-->> flux-red (term ("not" #f)) (term #t))
  (test-->> flux-red (term ("not" ("not" #f))) (term #f))
  (test-->> flux-red (term ("not" ("not" ("not" ("not" #f))))) (term #f))

  ;; FIXME () + ()
  ;; (test-->> flux-red (term ((#t "and" #f) "and" (#t "and" #f))) (term #f))
  ;; (test-->> flux-red (term ((#t "or" #f) "or" (#t "or" #f))) (term #f))

  ;; de Morgan's laws
  ;; (test-->> flux-red
  ;;           (term ("not" (#t "or" #t)))
  ;;           (term (("not" #t) "or" ("not" #t)))
  ;;           ))

  ;; (test-->> flux-red (term ("if" true "then" false "else" true)) (term false))
  ;; (test-->> flux-red (term (true "or" false)) (term true))
  ;; (test-->> flux-red (term (1 ">" (2 "^" 2))) (term false))
  ;; (test-->> flux-red (term (32 "!=" 31)) (term true))
  ;; (test-->> flux-red (term (true "==" false)) (term false))

  ;;
  )
