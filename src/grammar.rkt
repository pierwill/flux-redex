#lang racket
(require redex)

(provide Flux)

(define-language Flux

  ;; Packages
  ;; --------
  (PackageClause ("package" Identifier))
  (File StatementList
        (PackageClause StatementList)
        (ImportList StatementList)
        (PackageClause ImportList StatementList))
  (ImportList (ImportDeclaration ...))
  (ImportDeclaration ("import" StringLit)
                     ("import" Identifier StringLit))

  ;; Blocks
  ;; ------
  (Block 𝒰
         PackageBlock
         FileBlock
         FunctionLitBlock
         ("{" StatementList "}" ))

  ;; Statements
  ;; ----------
  (StatementList (Statement ...))
  (Statement OptionAssignment
             BuiltinStatement
             VariableAssignment
             ReturnStatement
             ExpressionStatement)

  (OptionAssignment ("option" OptionPath "=" Expression))
  (OptionPath Identifier (Identifier "." Identifier))

  (BuiltinStatement ("builtin" Identifier ":" TypeExpression))
  (TypeExpression MonoType (MonoType "where" Constraints))
  (MonoType Tvar BasicType ArrayType RecordType FunctionType)
  (Tvar "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z")
  (BasicType "int" "uint" "float" "string" "bool" "time" "duration") ; TODO "bytes" and "regex"
  (ArrayType ("[" MonoType "]"))
  (RecordType ("{" "}")
              ("{" RecordTypeProperties "}")
              ("{" Tvar "with" RecordTypeProperties "}"))
  (FunctionType ("(" ")" "=>" MonoType)
                ("(" FunctionTypeParameters ")" "=>" MonoType))
  (RecordTypeProperties (RecordTypeProperty RecordTypeProperty ...))
  (RecordTypeProperty (Label ":" MonoType))
  (Label Identifier StringLit)
  (FunctionTypeParameters (FunctionTypeParameter FunctionTypeParameter ...))
  (FunctionTypeParameter (Identifier ":" MonoType)
                         ("<-" Identifier ":" MonoType)
                         ("?" Identifier ":" MonoType))
  (Constraints (Constraint Constraint ...))
  (Constraint (Tvar ":" Kinds))
  ;; Kinds       = identifier { "+" identifier } .
  ;; TODO To "+" or not to "+"? That is the question.
  (Kinds (Identifier AdditionalIdentifier ...))
  (AdditionalIdentifier ("+" Identifier))
  (VariableAssignment (Identifier "=" Expression))

  (ReturnStatement ("return" Expression))

  (ExpressionStatement Expression)

  (PrimaryExpression Identifier
                     Literal
                     ("(" Expression ")"))

  ;; TODO decide how to handle this
  ;; identifier (letter { letter | unicode_digit } .
  (Identifier variable-not-otherwise-mentioned)

  (decimalDigit "0" "1" "2" "3" "4" "5" "6" "7" "8" "9")

  ;; Literals
  ;; --------
  (Literal IntLit
           FloatLit
           StringLit
           ;; regexLit
           DateTimeLit
           DurationLit
           PipeReceiveLit
           RecordLit
           ArrayLit
           DictLit
           FunctionLit)

  (IntLit integer)

  (FloatLit (decimals ".") (decimals "." decimals) ("." decimals))
  (decimals (decimalDigit decimalDigit ...))
  
  (StringLit string)

  ;; TODO maybe?
  ;; (regexLit)

  (DurationLit (durationMagnitude DurationUnit))
  (durationMagnitude integer)
  (DurationUnit "y" "mo" "w" "d" "h" "m" "s" "ms" "us" "μs" "ns")

  ;; TODO review all of these
  (DateTimeLit date (date "T" time))
  (date (year "-" month "-" day))
  (year (decimalDigit decimalDigit decimalDigit decimalDigit))
  (month (decimalDigit decimalDigit))
  (day (decimalDigit decimalDigit))
  (time (hour ":" minute ":" second)
        (hour ":" minute ":" second fractionalSecond)
        (hour ":" minute ":" second timeOffset)
        (hour ":" minute ":" second fractionalSecond timeOffset))
  (hour (decimalDigit decimalDigit))
  (minute (decimalDigit decimalDigit))
  (second (decimalDigit decimalDigit))
  (fractionalSecond ("." (decimalDigit ...)))
  (timeOffset "Z" ("+" hour ":" minute) ("-" hour ":" minute))

  (RecordLit ("{" RecordBody "}"))
  (RecordBody WithProperties PropertyList)
  (WithProperties (Identifier "with" PropertyList))
  (PropertyList (Property ...))
  (Property Identifier
            (Identifier ":" Expression)
            (StringLit ":" Expression))

  (ArrayLit ("[" ExpressionList "]"))
  (ExpressionList (Expression ...))

  (DictLit EmptyDict ("[" AssociativeList "]"))
  (EmptyDict ("[" ":" "]"))
  (AssociativeList (Association AssociativeList ...))
  (Association (Expression ":" Expression))

  (FunctionLit (FunctionParameters "=>" FunctionBody))

  (FunctionParameters EmptyParameterList
                      ("(" ParameterList ")")
                      ("(" ParameterList "," ")")) ; spec means to allow trailing comma?
  (EmptyParameterList "()")

  (ParameterList (Parameter Parameter ...))

  (Parameter Identifier (Identifier "=" Expression))

  (FunctionBody Expression Block)

  (CallExpression ( "(" PropertyList ")" ))

  (PipeReceiveLit "<-")

  (IndexExpression ("[" Expression "]"))

  (MemberExpression DotExpression MemberBracketExpression)
  (DotExpression ("." Identifier))
  (MemberBracketExpression ("[" StringLit "]"))

  ;; Operators
  ;; ---------
  (LogicalOperator "and" "or")
  (UnaryLogicalOperator "not" "exists")
  (ComparisonOperator "=="  "!="  "<"  "<="  ">"  ">="  "=~"  "!~")
  (AdditiveOperator "+" "-")
  (MultiplicativeOperator "*" "/" "%")
  (ExponentOperator "^")
  (PipeOperator "|>")
  (PrefixOperator "+" "-")
  (PostfixOperator MemberExpression CallExpression IndexExpression)

  ;; Expressions
  ;; -----------
  ;;
  ;; (Includes operator precedence)
  (Expression ConditionalExpression)

  (ConditionalExpression LogicalExpression
                         ("if" Expression "then" Expression "else" Expression))

  (LogicalExpression UnaryLogicalExpression
                     (LogicalExpression LogicalOperator UnaryLogicalExpression))

  (UnaryLogicalExpression ComparisonExpression
                          (UnaryLogicalOperator UnaryLogicalExpression))

  (ComparisonExpression AdditiveExpression
                        (ComparisonExpression ComparisonOperator AdditiveExpression))

  (AdditiveExpression MultiplicativeExpression
                      (AdditiveExpression AdditiveOperator MultiplicativeExpression))

  (MultiplicativeExpression ExponentExpression
                            (ExponentExpression MultiplicativeOperator MultiplicativeExpression))

  (ExponentExpression PipeExpression
                      (ExponentExpression ExponentOperator PipeExpression))

  (PipeExpression PostfixExpression
                  (PipeExpression PipeOperator UnaryExpression))

  (UnaryExpression PostfixExpression
                   (PrefixOperator UnaryExpression))

  (PostfixExpression PrimaryExpression
                     (PostfixExpression PostfixOperator))
  ;;
  )
