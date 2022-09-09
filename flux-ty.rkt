#lang racket
(require redex
         "flux.rkt")

(provide Flux-ty)

(define-extended-language Flux-ty Flux

  (Statement ....
             BuiltinStatement)

  ;; A type defines the set of values and operations on those values.
  ;; Types are never explicitly declared as part of the syntax except as part of a builtin statement.
  ;; Types are always inferred from the usage of the value.
  ;; Type inference follows a Hindley-Milner style inference system.
  ;;
  ;; TODO union types? https://docs.influxdata.com/flux/v0.x/spec/types/#union-types
  (type "null"
        Boolean
        integer ;; uint | int | float
        Time
        duration
        string
        ;; bytes
        ;; regex
        array
        record
        dictionary
        function
        generator
        )

  (Boolean boolean "null")

  (BuiltinStatement ("builtin" Identifier ":" TypeExpression))
  ;; TODO does this all belong to/in the type system?
  ;; TypeExpression   = MonoType ["where" Constraints] .
  (TypeExpression MonoType (MonoType "where" Constraints))
  (MonoType Tvar Basic Array Record Function)
  ;; Tvar     = "A" ... "Z" .
  ;; FIXME
  (Tvar string)
  (Basic null int uint float string bool time duration) ; TODO "bytes" and "regex"
  (Array ("[" MonoType "]"))
  ;; Record   = ( "{" [Properties] "}" ) | ( "{" Tvar "with" Properties "}" ) .
  ;; FIXME
  (Record ("{" (Properties ...) "}") ("{" Tvar "with" Properties "}") )
  ;; Function = "(" [Parameters] ")" "=>" MonoType .
  ;; FIXME
  (Function ("(" Parameters ")" "=>" MonoType))
  ;; Properties = Property { "," Property } .
  (Properties (Property-in-builtin ...))
  ;; TODO defining property twice?
  (Property-in-builtin (Label ":" MonoType))
  (Label Identifier StringLit)
  ;; Parameters = Parameter { "," Parameter } .
  (Parameters (Parameter-in-builtin ...))
  (Parameter-in-builtin (Identifier ":" Monotype)
                        ("<-" Identifier ":" MonoType)
                        ("?" Identifier ":" MonoType))
  ;; Constraints = Constraint { "," Constraint } .
  ;; FIXME
  (Constraints (Constraint ...))
  (Constraint (Tvar ":" Kinds))
  ;; Kinds       = identifier { "+" identifier } .
  ;; FIXME
  (Kinds Identifier)

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
