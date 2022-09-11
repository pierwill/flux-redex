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
   ;; TODO exists
   (--> (Expression_1 "*" Expression_2)
        ,(* (term Expression_1) (term Expression_2))
        "multiply")
   (--> (Expression_1 "/" Expression_2)
        ,(/ (term Expression_1) (term Expression_2))
        "divide")
   ;; TODO %
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
   ;; TODO "=~"
   ;; TODO "!~"
   ;; FIXME after bugfix
   ;; (--> (Expression_1 "+" Expression_2)
   ;;      ,(+ (term Expression_1) (term Expression_2))
   ;;      "add")
   ;;    (--> (Expression_1 "-" Expression_2)
   ;;      ,(- (term Expression_1) (term Expression_2))
   ;;      "subtract")
   (--> (Expression_1 "^" Expression_2)
        ,(expt (term Expression_1) (term Expression_2))
        "exponentiation")
   ;; TODO (PipeOperator "|>")
   ;; TODO (PrefixOperator "+" "-")

   ;; TODO do these unary prefix operators only apply to durations?
   ;; (--> ("+" Expression)
   ;;      ,(+ (term Expression))
   ;;      "pos num")
   ;; (--> ("-" Expression)
   ;;      ,(- (term Expression))
   ;;      "neg num")
   ))
