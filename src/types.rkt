#lang racket
(require redex
         "grammar.rkt")

(provide Flux-ty)

(define-extended-language Flux-ty Flux

  ;; A type defines the set of values and operations on those values.
  ;; Types are never explicitly declared as part of the syntax except as part of a builtin statement.
  ;; Types are always inferred from the usage of the value.
  ;; Type inference follows a Hindley-Milner style inference system.
  ;;
  ;; TODO union types? https://docs.influxdata.com/flux/v0.x/spec/types/#union-types
  (Type "null"
        Boolean
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
  (Boolean boolean "null")

  ;; Type constraints are a type system concept used to implement static ad hoc polymorphism.
  ;; For example, `add = (a, b) => a + b` is a function that is defined only for `Addable` types.
  ;; If one were to pass a record to `add` like so:
  ;;
  ;;     add(a: {}, b: {})
  ;;
  ;; the result would be a compile-time type error because records are not addable.
  ;; Like types, constraints are never explicitly declared but rather inferred from the context.
  (TypeConstraint Addable
                  Subtractable
                  Divisable
                  Numeric
                  Comparable
                  Equatable
                  Nullable
                  Record
                  Negatable
                  Timeable
                  Stringable)

  ;;
  )

;; Divisible types are those the binary arithmetic operator \ accepts.
;; Int, Uint, and Float types are Divisible.
(define-metafunction Flux-ty
  is_divisable : Type -> boolean
  [(is_divisable Uint) #t]
  [(is_divisable Int) #t]
  [(is_divisable Float) #t]
  [(is_divisable _) #f]
  )

;; Int, Uint, and Float types are Numeric.
(define-metafunction Flux-ty
  is_numeric : Type -> boolean
  [(is_numeric Uint) #t]
  [(is_numeric Int) #t]
  [(is_numeric Float) #t]
  [(is_numeric _) #f]
  )

;; Equatable types are those that can be compared for equality using the == or != operators.
;; Bool, Int, Uint, Float, String, Duration, Time, Bytes, Array, and Record types are Equatable.
(define-metafunction Flux-ty
  is_equatable : Type -> boolean
  [(is_equatable Bool) #t]
  [(is_equatable Uint) #t]
  [(is_equatable Int) #t]
  [(is_equatable Float) #t]
  [(is_equatable String) #t]
  [(is_equatable Duration) #t]
  [(is_equatable Time) #t]
  ;; [(is_equatable Bytes) #t]
  [(is_equatable Array) #t]
  [(is_equatable Record) #t]
  [(is_equatable _) #f]
  )

;; Nullable types are those that can be null.
;; Bool, Int, Uint, Float, String, Duration, and Time types are Nullable.
(define-metafunction Flux-ty
  is_nullable : Type -> boolean
  [(is_equatable Bool) #t]
  [(is_equatable Uint) #t]
  [(is_equatable Int) #t]
  [(is_equatable Float) #t]
  [(is_equatable String) #t]
  [(is_equatable Duration) #t]
  [(is_equatable Time) #t]
  )

;; Addable types are those the binary arithmetic operator + accepts.
;; Int, Uint, Float, and String types are Addable.
(define-metafunction Flux-ty
  is_addable : Type -> boolean
  [(is_addable Int) #t]
  [(is_addable Uint) #t]
  [(is_addable Float) #t]
  [(is_addable String) #t]
  [(is_addable _) #f]
  )

;; Subtractable types are those the binary arithmetic operator - accepts.
;; Int, Uint, and Float types are Subtractable.
(define-metafunction Flux-ty
  is_subtractable : Type -> boolean
  [(is_subtractable Int) #t]
  [(is_subtractable Uint) #t]
  [(is_subtractable Float) #t]
  [(is_subtractable _) #f]
  )

;; Comparable types are those the binary comparison operators <, <=, >, or >= accept.
;; Int, Uint, Float, String, Duration, and Time types are Comparable.
(define-metafunction Flux-ty
  is_comparable : Type -> boolean
  [(is_comparable Int) #t]
  [(is_comparable Uint) #t]
  [(is_comparable Float) #t]
  [(is_comparable String) #t]
  [(is_comparable Duration) #t]
  [(is_comparable Time) #t]
  [(is_comparable _) #f]
  )

;; Records are the only types that fall under this constraint.
(define-metafunction Flux-ty
  is_record : Type -> boolean
  [(is_record Record) #t]
  [(is_record _) #f]
  )

;; Negatable types ore those the unary arithmetic operator - accepts.
;; Int, Uint, Float, and Duration types are Negatable.
;; Duration and Time types are Timeable.
(define-metafunction Flux-ty
  is_timeable : Type -> boolean
  [(is_timeable Int) #t]
  [(is_timeable Uint) #t]
  [(is_timeable Float) #t]
  [(is_timeable Duration) #t]
  [(is_timeable _) #f]
  )

;; Stringable types can be evaluated and expressed in string interpolation.
;; String, Int, Uint, Float, Bool, Time, and Duration types are Stringable.
(define-metafunction Flux-ty
  is_stringable : Type -> boolean
  [(is_stringable Int) #t]
  [(is_stringable Uint) #t]
  [(is_stringable Float) #t]
  [(is_stringable Bool) #t]
  [(is_stringable Time) #t]
  [(is_stringable Duration) #t]
  [(is_stringable _) #f]
  )

(term (is_divisable "null"))
