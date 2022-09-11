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
)

(define-metafunction Flux
  is_divisable : Type -> boolean
  [(is_divisable Uint) #t]
  [(is_divisable Int) #t]
  [(is_divisable Float) #t]
  )

;; Addable types are those the binary arithmetic operator + accepts. Int, Uint, Float, and String types are Addable.
;; Subtractable types are those the binary arithmetic operator - accepts. Int, Uint, and Float types are Subtractable.
;; Divisible types are those the binary arithmetic operator \ accepts. Int, Uint, and Float types are Divisible.
;; Int, Uint, and Float types are Numeric.
;; Comparable types are those the binary comparison operators <, <=, >, or >= accept. Int, Uint, Float, String, Duration, and Time types are Comparable.
;; Equatable types are those that can be compared for equality using the == or != operators. Bool, Int, Uint, Float, String, Duration, Time, Bytes, Array, and Record types are Equatable.
;; Nullable types are those that can be null. Bool, Int, Uint, Float, String, Duration, and Time types are Nullable.
;; Records are the only types that fall under this constraint.
;; Negatable types ore those the unary arithmetic operator - accepts. Int, Uint, Float, and Duration types are Negatable.
;; Duration and Time types are Timeable.
;; Stringable types can be evaluated and expressed in string interpolation. String, Int, Uint, Float, Bool, Time, and Duration types are Stringable.
