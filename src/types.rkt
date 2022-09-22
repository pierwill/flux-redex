#lang racket
(require redex
         ;; "grammar.rkt"
         "reduction.rkt")

(define-extended-language Flux-ty Flux-eval

  (TypeVar ::= Identifier)

  ;; when you have an unknown type, make a fresh type, put it in gamma
  (Gamma ::= ((TypeVar ...)
              [(TypeVar Type) ...]
              [(VarName Type) ...]))

  (Type ::= TypeVar
        
        "null"
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
        Generator
        )
  ;;
  )

(define-judgment-form Flux-ty
  #:mode (has-type I I O O)
  #:contract (has-type Gamma Expression Type Gamma)

  [
   (where (_ _ [_ ... (VarName Type) _ ...]) Gamma)
   -------------------------
   (has-type Gamma VarName Type Gamma)
   ]

  [
   ---------------------- "string"
   (has-type Gamma StringLit String Gamma)
   ]

  [
   ---------------------- "float"
   (has-type Gamma FloatLit Float Gamma)
   ]

  [
   (has-type Gamma_0 Expression_1 Bool Gamma_1)
   (has-type Gamma_1 Expression_2 Type Gamma_2)
   (has-type Gamma_2 Expression_3 Type Gamma_3) ; they have to have same type, otherwise we're not doing algo W
   ------------------------------- "ifthenelse"
   (has-type Gamma_0 ("if" Expression_1 "then" Expression_2 "else" Expression_3) Type Gamma_3)
   ]

  ;;
  )

(module+ test

  (test-judgment-holds (has-type (() () ()) (("1" "1") ".") Float (() () ())))
  (test-judgment-holds (has-type (() () ()) "αδελφός" String (() () ())))

  ;; (test-judgment-holds (has-type
  ;;                       (() () ([true #t] [false #f]))
  ;;                       (term ("if" true "then" false "else" true))
  ;;                       Bool

  ;;                       (() () ())))
  
  ;;
  )
