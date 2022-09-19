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

  ;; Group key
  ;;
  ;; A group key defines which columns and specific column values to include in a table.
  ;; All rows in a table contain the same values in group key columns.
  ;; All tables in a stream of tables have a unique group key, but group key modifications are applied to a stream of tables.
  ;;
  ;; Example group keys
  ;;
  ;; Group keys contain key-value pairs,
  ;; where each key represents a column name and each value represents the column value included in the table.
  ;; The following are examples of group keys in a stream of tables with three separate tables.
  ;; Each group key represents a table containing data for a unique location:
  ;;
  ;; [_measurement: "production", facility: "us-midwest", _field: "apq"]
  ;; [_measurement: "production", facility: "eu-central", _field: "apq"]
  ;; [_measurement: "production", facility: "ap-east", _field: "apq"]
  (GroupKey ::= ((Identifier Column) ...))

  (ColumnType ::= "bool" "uint" "int" "float" "string" "bytes" "time" "duration" )

  ;;
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
