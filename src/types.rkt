#lang racket
(require redex
         "reduction.rkt")

(define-extended-language Flux-ty Flux-eval

  ;; Gamma is a type environment.
  (Gamma ::= ((TypeVar ...)
              [(TypeVar Type) ...]
              [(VarName Type) ...]))

  (Type ::= TypeVar
        Null
        Bool
        Uint
        Int
        Float
        Time
        Duration
        String
        Array
        Record
        Dictionary
        Function
        Generator)
  (TypeVar ::= Identifier)
  ;;
  )

(define-judgment-form Flux-ty
  #:mode (has-type I I O O)
  #:contract (has-type Gamma Expression Type Gamma)

  [
   (where (_ _ [_ ... (VarName Type) _ ...]) Gamma)
   ------------------------------------------------ "var"
   (has-type Gamma VarName Type Gamma)
   ]

  [
   --------------------------------------- "string"
   (has-type Gamma StringLit String Gamma)
   ]

  [
   ------------------------------------- "float"
   (has-type Gamma FloatLit Float Gamma)
   ]

  [
   (has-type Gamma_0 Expression_1 Bool Gamma_1)
   (has-type Gamma_1 Expression_2 Bool Gamma_2)
   ----------------------------------------------------------------- "and"
   (has-type Gamma_0 (Expression_1 "and" Expression_2) Bool Gamma_2)
   ]

  [
   (has-type Gamma_0 Expression_1 Bool Gamma_1)
   (has-type Gamma_1 Expression_2 Bool Gamma_2)
   ---------------------------------------------------------------- "or"
   (has-type Gamma_0 (Expression_1 "or" Expression_2) Bool Gamma_2)
   ]

  [
   (has-type Gamma_0 Expression Bool Gamma_1)
   -------------------------------------------------- "not"
   (has-type Gamma_0 ("not" Expression) Bool Gamma_1)
   ]

  [
   ---------------------------------- "null"
   (has-type Gamma "null" Null Gamma)
   ]

  [
   ------------------------------------------------- "exists"
   (has-type Gamma ("exists" Expression) Bool Gamma)
   ]

  [
   (has-type Gamma_0 Expression_1 Bool Gamma_1)
   (has-type Gamma_1 Expression_2 Type Gamma_2)
   (has-type Gamma_2 Expression_3 Type Gamma_3)
   -------------------------------------------- "ifthenelse"
   (has-type Gamma_0
             ("if" Expression_1 "then" Expression_2 "else" Expression_3)
             Type Gamma_3)
   ]

  [
   (has-type Gamma_0 Expression_1 Type Gamma_1)
   (has-type Gamma_1 Expression_2 Type Gamma_2)
   -------------------------------------------- "array2"
   (has-type Gamma_0 ("[" (Expression_1 Expression_2) "]") Array Gamma_2)
   ]

  ;; [
  ;;  (has-type Gamma_0 Expression_1 Type Gamma_1)
  ;;  (has-type Gamma_1 Expression_2 Type Gamma_2)
  ;;  ------------------------------- "comparison"
  ;;  (has-type Gamma_0 (Expression_1 ComparisonOperator Expression_2) Bool Gamma_2)
  ;;  ]

  ;; TODO Variable assignments should insert into Gamma, yes?

  ;; These involve numeric types:
  ;; TODO ComparisonExpression
  ;; TODO AdditiveExpression
  ;; TODO MultiplicativeExpression
  ;; TODO ExponentExpression

  ;; TODO PipeExpression

  ;; TODO UnaryExpression (prefix operators for durations?)

  ;; PostfixExpression

  ;;
  )

(module+ test

  (test-judgment-holds (has-type (() () ()) "αδελφός" String (() () ())))
  (test-judgment-holds (has-type (() () ()) (("1" "1") ".") Float (() () ())))

  (test-judgment-holds (has-type
                        (() () ([true Bool] [false Bool])) ; Gamma_in
                        true
                        Bool

                        (() () ([true Bool] [false Bool]))) ; Gamma_out
                       )

  (test-judgment-holds (has-type
                        (() () ([true Bool] [false Bool])) ; Gamma_in
                        (true "and" false)
                        Bool

                        (() () ([true Bool] [false Bool]))) ; Gamma_out
                       )

  (test-judgment-holds (has-type
                        (() () ([true Bool] [false Bool])) ; Gamma_in
                        (true "or" false)
                        Bool

                        (() () ([true Bool] [false Bool]))) ; Gamma_out
                       )

  (test-judgment-holds (has-type
                        (() () ([true Bool] [false Bool])) ; Gamma_in
                        ("not" false)
                        Bool

                        (() () ([true Bool] [false Bool]))) ; Gamma_out
                       )

  (test-judgment-holds (has-type
                        (() () ([true Bool] [false Bool])) ; Gamma_in
                        ("if" true "then" "foo" "else" "bar")
                        String

                        (() () ([true Bool] [false Bool]))) ; Gamma_out
                       )

  (test-judgment-holds (has-type
                        (() () ([true Bool] [false Bool])) ; Gamma_in
                        "null"
                        Null

                        (() () ([true Bool] [false Bool]))) ; Gamma_out
                       )

  (test-judgment-holds (has-type
                        (() () ()) ; Gamma_in
                        ("exists" "null")
                        Bool

                        (() () ())) ; Gamma_out
                       )

  (test-judgment-holds (has-type
                        (() () ([true Bool] [false Bool])) ; Gamma_in
                        ("exists" true)
                        Bool

                        (() () ([true Bool] [false Bool]))) ; Gamma_out
                       )

  (test-judgment-holds (has-type
                        (() () ()) ; Gamma_in
                        ("[" ("foo" "bar") "]")
                        Array

                        (() () ())) ; Gamma_out
                       )

  ;; FIXME? this shouldn't work, I don't think...
  (test-judgment-holds (has-type
                        (() () ()) ; Gamma_in
                        ("[" ("foo" "null") "]")
                        Array

                        (() () ())) ; Gamma_out
                       )

  ;; (test-judgment-holds (has-type
  ;;                       (() () ()) ; Gamma_in
  ;;                       ("foo" "<" "bar") ; we can compare strings by lexicographic
  ;;                       Bool

  ;;                       (() () ())) ; Gamma_out
  ;;                      )

  ;;
  )
