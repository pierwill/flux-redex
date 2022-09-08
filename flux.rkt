#lang racket
(require redex)

(provide Flux)

(define-language Flux

  (packageClause ("package" identifier))

  ;; File = [ PackageClause ] [ ImportList ] StatementList .
  (file (packageClause importList statementList))

  ;; ImportList = { ImportDeclaration } .
  (importList (ImportDeclaration ...))

  (type "null"
        boolean
        string

        Time
        duration

        array
        record
        dictionary
        function
        generator
        )

  (constraint addable
              subtractable
              divisable
              numeric
              comparable
              equatable
              nullable
              record
              negatable
              timeable
              stringable)

  (statement optionAssignment
             builtinStatement
             variableAssignment
             returnStatement
             expressionStatement)

  (expressionStatement expression)

  (returnStatement ("return" expression))

  (expression identifier
              literal
              ("(" expression ")"))

  (identifier variable-not-otherwise-mentioned)
  
  (literal intLit
           floatLit
           stringLit
           regexLit
           durationLit
           datetimeLit
           pipeReceiveLit
           recordLit
           arrayLit
           dictLit
           functionLit)

  (intLit integer)

  (keyword "and"
           "import"
           "not"
           "return"
           "option"
           "test"
           "empty"
           "in"
           "or"
           "package"
           "builtin")

  (assignment (identifier "=" expression))

  ;; identifier (letter { letter | unicode_digit } .
  ;; (identifier (letter (letter )

  (operators
   "+"
   "=="
   "!="
   "("
   ")"
   "=>"
   "-"
   "<"
   "!~"
   "["
   "]"
   "^"
   "*"
   ">"
   "=~"
   "{"
   "}"
   "/"
   "<="
   "="
   ","
   ":"
   "%"
   ">="
   "<-"
   "."
   "|>"
   )

  (durationLit (intLit durationUnit))

  (durationUnit
   "y"
   "mo"
   "w"
   "d"
   "h"
   "m"
   "s"
   "ms"
   "us"
   "μs"
   "ns"
   )

  ;; date_time_lit     = date [ "T" time ] .
  ;; date              = year "-" month "-" day .
  ;; year              = decimal_digit decimal_digit decimal_digit decimal_digit .
  ;; month             = decimal_digit decimal_digit .
  ;; day               = decimal_digit decimal_digit .
  ;; time              = hour ":" minute ":" second [ fractional_second ] [ time_offset ] .
  ;; hour              = decimal_digit decimal_digit .
  ;; minute            = decimal_digit decimal_digit .
  ;; second            = decimal_digit decimal_digit .
  ;; fractional_second = "."  { decimal_digit } .
  ;; time_offset       = "Z" | ("+" | "-" ) hour ":" minute .
  )

