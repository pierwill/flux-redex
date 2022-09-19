#lang racket
(require redex
         "reduction.rkt")

(define-extended-language Flux-data Flux-eval
  ;; A stream of tables is a collection of zero or more tables.
  ;; Data sources return results as a stream of tables.
  (StreamOfTables ::= (Table ...))
  ;; A table is a collection of columns partitioned by group key.
  (Table ::= (Column ...))
  ;; A column is a collection of values of the same basic type that contains one value for each row.
  ;; (Column ::= (Value ...))
  (Column ::= (Row ...))
  ;; A row is a collection of associated column values.
  (Row ::= (Val ...))

  ;; A group key defines which columns and specific column values to include
  ;; in a table. All rows in a table contain the same values in group key columns.
  ;; All tables in a stream of tables have a unique group key, but group key
  ;; modifications are applied to a stream of tables.
  ;; (GroupKey ::=

  (ColumnType ::=
              "bool"     ;; a boolean value, true or false.
              "uint"     ;; an unsigned 64-bit integer
              "int"      ;; a signed 64-bit integer
              "float"    ;; an IEEE-754 64-bit floating-point number
              "string"   ;; a sequence of unicode characters
              "bytes"    ;; a sequence of byte values
              "time"     ;; a nanosecond precision instant in time
              "duration" ;; a nanosecond precision duration of time
              )
  )

(test-match Flux-data Row (term (#t)))
(test-match Flux-data Column (term ((#t) (#t) (#t))))
(define col (term ((#t) (#t) (#t))))
(test-match Flux-data Table (term (,col ,col ,col)))
(define tabl (term (,col ,col ,col)))
(test-match Flux-data StreamOfTables (term (,tabl ,tabl ,tabl)))

(define flux-data-model
  (extend-reduction-relation
   flux-red Flux-data

   ;; TODO

   ))
