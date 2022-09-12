#lang racket
(require redex
         "grammar.rkt")

(provide Flux-ty
         is-addable
         is-subtractable
         is-numeric
         is-comparable
         is-equatable
         is-nullable
         is-record
         is-negatable
         is-timeable
         is-stringable
         )

(define-extended-language Flux-ty Flux

  ;; A type defines the set of values and operations on those values.
  ;; Types are never explicitly declared as part of the syntax except as part of a builtin statement.
  ;; Types are always inferred from the usage of the value.
  ;; Type inference follows a Hindley-Milner style inference system.
  ;;
  ;; TODO union types? https://docs.influxdata.com/flux/v0.x/spec/types/#union-types
  (Type "null"
        Bool
        Uint
        Int
        Float
        Time
        Duration
        String
        ;; bytes
        ;; regex
        Array
        Record
        Dictionary
        Function
        Generator
        )

  ;;
  )

;; Type constraints are a type system concept used to implement static ad hoc polymorphism.
;; For example, `add = (a, b) => a + b` is a function that is defined only for `Addable` types.
;; If one were to pass a record to `add` like so:
;;
;;     add(a: {}, b: {})
;;
;; the result would be a compile-time type error because records are not addable.
;; Like types, constraints are never explicitly declared but rather inferred from the context.
;;
;; (TypeConstraint Addable Subtractable Divisable Numeric Comparable Equatable Nullable Record Negatable Timeable Stringable)

;; Addable types are those the binary arithmetic operator + accepts.
;; Int, Uint, Float, and String types are Addable.
(define-metafunction Flux-ty
  is-addable : Type -> boolean
  [(is-addable Int) #t]
  [(is-addable Uint) #t]
  [(is-addable Float) #t]
  [(is-addable String) #t]
  [(is-addable _) #f]
  )

;; Subtractable types are those the binary arithmetic operator - accepts.
;; Int, Uint, and Float types are Subtractable.
(define-metafunction Flux-ty
  is-subtractable : Type -> boolean
  [(is-subtractable Int) #t]
  [(is-subtractable Uint) #t]
  [(is-subtractable Float) #t]
  [(is-subtractable _) #f]
  )

;; Divisible types are those the binary arithmetic operator \ accepts.
;; Int, Uint, and Float types are Divisible.
(define-metafunction Flux-ty
  is-divisable : Type -> boolean
  [(is-divisable Uint) #t]
  [(is-divisable Int) #t]
  [(is-divisable Float) #t]
  [(is-divisable _) #f]
  )

;; Int, Uint, and Float types are Numeric.
(define-metafunction Flux-ty
  is-numeric : Type -> boolean
  [(is-numeric Uint) #t]
  [(is-numeric Int) #t]
  [(is-numeric Float) #t]
  [(is-numeric _) #f]
  )

;; Comparable types are those the binary comparison operators <, <=, >, or >= accept.
;; Int, Uint, Float, String, Duration, and Time types are Comparable.
(define-metafunction Flux-ty
  is-comparable : Type -> boolean
  [(is-comparable Int) #t]
  [(is-comparable Uint) #t]
  [(is-comparable Float) #t]
  [(is-comparable String) #t]
  [(is-comparable Duration) #t]
  [(is-comparable Time) #t]
  [(is-comparable _) #f]
  )

;; Equatable types are those that can be compared for equality using the == or != operators.
;; Bool, Int, Uint, Float, String, Duration, Time, Bytes, Array, and Record types are Equatable.
(define-metafunction Flux-ty
  is-equatable : Type -> boolean
  [(is-equatable Bool) #t]
  [(is-equatable Uint) #t]
  [(is-equatable Int) #t]
  [(is-equatable Float) #t]
  [(is-equatable String) #t]
  [(is-equatable Duration) #t]
  [(is-equatable Time) #t]
  ;; [(is-equatable Bytes) #t]
  [(is-equatable Array) #t]
  [(is-equatable Record) #t]
  [(is-equatable _) #f]
  )

;; Nullable types are those that can be null.
;; Bool, Int, Uint, Float, String, Duration, and Time types are Nullable.
(define-metafunction Flux-ty
  is-nullable : Type -> boolean
  [(is-nullable Bool) #t]
  [(is-nullable Uint) #t]
  [(is-nullable Int) #t]
  [(is-nullable Float) #t]
  [(is-nullable String) #t]
  [(is-nullable Duration) #t]
  [(is-nullable Time) #t]
  [(is-nullable _) #f]
  )

;; Records are the only types that fall under this constraint.
(define-metafunction Flux-ty
  is-record : Type -> boolean
  [(is-record Record) #t]
  [(is-record _) #f]
  )

;; Duration and Time types are Timeable.
(define-metafunction Flux-ty
  is-timeable : Type -> boolean
  [(is-timeable Duration) #t]
  [(is-timeable Time) #t]
  [(is-timeable _) #f]
  )

;; Negatable types ore those the unary arithmetic operator - accepts.
;; Int, Uint, Float, and Duration types are Negatable.
(define-metafunction Flux-ty
  is-negatable : Type -> boolean
  [(is-negatable Int) #t]
  [(is-negatable Uint) #t]
  [(is-negatable Float) #t]
  [(is-negatable Duration) #t]
  [(is-negatable _) #f]
  )

;; Stringable types can be evaluated and expressed in string interpolation.
;; String, Int, Uint, Float, Bool, Time, and Duration types are Stringable.
(define-metafunction Flux-ty
  is-stringable : Type -> boolean
  [(is-stringable Int) #t]
  [(is-stringable Uint) #t]
  [(is-stringable Float) #t]
  [(is-stringable Bool) #t]
  [(is-stringable Time) #t]
  [(is-stringable Duration) #t]
  [(is-stringable _) #f]
  )

;; TODO a function to get type/type constraints?

(module+ test
  (test-equal (term (is-divisable "null")) #f)
  (test-equal (term (is-record Record)) #t)
  (test-equal (term (is-equatable Bool)) #t)
  (test-equal (term (is-nullable Bool)) #t)
  (test-equal (term (is-nullable Array)) #f)
  )
