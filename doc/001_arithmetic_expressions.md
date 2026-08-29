# 1. Arithmetic Expressions and Comments

This document defines the first iteration of the arithmetic expressions and comments of language specification.

The purpose of this document is to establish:

- Numeric data types
- Arithmetic calculations
- Expression evaluation rules
- Comment syntax
- Basic lexical structure

---

# 2. Lexical Structure

## 2.1 Character Encoding

Source files shall be encoded in UTF-8.

---

## 2.2 Whitespace

Whitespace is ignored except where it separates tokens.

Whitespace includes:

- Space (` `)
- Tab (`\t`)
- Line break (`\n`)
- Carriage return (`\r`)

Example:

```txt
1+2
```

is equivalent to

```txt
1 + 2
```

---

# 3. Comments

Comments are ignored by the compiler.

---

## 3.1 Single-Line Comments

Syntax:

```txt
// comment text
```

Everything following `//` until the end of the line is ignored.

Example:

```txt
5 + 3  // add two numbers
```

---

## 3.2 Multi-Line Comments

Syntax:

```txt
/*
comment
text
*/
```

Everything between `/*` and `*/` is ignored.

Example:

```txt
/*
Calculate invoice total
*/
100 + 50
```

---

# 4. Data Types

## 4.1 Integer

Represents whole numbers without a decimal point.

Examples:

```txt
0
1
42
-19
1000000
```

### Properties

| Property        | Value   |
|-----------------|---------|
| Category        | Numeric |
| Fractional Part | No      |
| Signed          | Yes     |

---

## 4.2 Decimal

Represents numbers with a fractional component.

Examples:

```txt
3.14
0.5
-10.75
```

### Properties

| Property        | Value   |
|-----------------|---------|
| Category        | Numeric |
| Fractional Part | Yes     |
| Signed          | Yes     | 

---

# 4.3 Type Promotion

When an operation combines:

```txt
Integer + Decimal
```

or

```txt
Integer - Decimal
```

or

```txt
Iteger * Decimal
```

or

```txt
Integer / Decimal
```

The Integer operand shall be promoted to Decimal before evaluation.

Example:

```txt
5 + 2.5
```

Evaluation:

```txt
5.0 + 2.5
```

*esult:

```txt
7.5
```

---

# 5. Literals

Numeric literals are written directly in source code.

## Integer Literals

Syntax:

```ebnf
IntegerLiteral = Digit , { Digit } ;
```

Examples:

```txt
0
1
999
```

---

## Decimal Literals

Syntax:

```ebnf
DecimalLiteral =
    IntegerLiteral ,
    ".",
    IntegerLiteral ;
```

Examples:

```txt
1.0
3.14
12.99
```

*--

# 6. Expressions

An expression produces a value.

Examples:

```txt
5
10 + 2
8 * 3
```

---

# 7. Arithmetic Operators

## 7.1 Addition

Syntax:

```txt
expression + expression
```

Meaning:

Returns the sum of both operands.

Example:

```txt
4 + 2
```

Result:

```txt
6
```

---

## 7.2 Subtraction

Syntax:

```txt
expression - expression
```

Meaning:

Returns the left operand minus the right operand.

Example:

```txt
10 - 3
```

Result:

```txt
7
```

---

## 7.3 Multiplication

Syntax:

```txt
expression * expression
```

Meaning:

Returns the product of both operands.

Example:

```txt
5 * 4
```

Resul*:

```txt
20
```

---

## 7.4 Division

Syntax:

```txt
expression / expression
```

Meaning:

Returns the quotient of the left operand divided by the right operand.

Example:

```txt
20 / 4
```

Result:

```txt
5
```

### Division by Zero

Division by zero shall produce a runtime error.

Example:

```txt
10 / 0
```

Result:

```txt
RuntimeError: DivisionByZero
```

---

# 8. Operator Precedence

Operators are evaluated according to the following precedence rules.

| Level | Operators |
|-------|-----------|
| 1     | `* `/`    |
| 2     | `+` `-`   |

Higher precedence operators are evaluated first.

Example:

```txt
1 + 2 * 3
```

Evaluation:

```txt
1 + 6
```

Result:

```txt
7
```

---

# 9. Associativity

All arithmetic operators are left-associative.

Example:

```txt
20 / 5 / 2
```

Equivalent to:

```txt
(20 / 5) / 2
```

Evaluation:

```txt
4 / 2
```

Result:

```txt
2
```

---

# 10. Parenthesized Expressions

Parentheses override operator precedence.

Syntax:

```txt
( expression )
```

Example:

```txt
(1 + 2) * 3
```

Evaluation:

```txt
3 * 3
```

Result:

```txt
9
```

---

# 11. Semantics

## 11.* Evaluation Order

Expressions shall be evaluated from left to right while respecting:

1. Parentheses
2. Operator precedence
3. Associativity rules

---

## 11.2 Deterministic Evaluation

Given the same input program, the implementation shall always produce the same result.

Example:

```txt
4 + 5
```

Always evaluates to:

```txt
9
```

---

# 12. Grammar

## 12.1 EBNF

```ebnf
Program
    = Expression ;

Expression
    = AdditiveExpression ;

AdditiveExpression
    = MultiplicativeExpression ,
      { ("+" | "-") ,
      MultiplicativeExpression } ;
MultiplicativeExpression
    = PrimaryExpression ,
      { ("*" | "/"* ,
      PrimaryExpression } ;

PrimaryExpression
    = IntegerLiteral
    | DecimalLiteral
    | "(" , Expression , ")" ;

IntegerLiteral
    = Digit , { Digit } ;

DecimalLiteral
    = IntegerLiteral ,
      "." ,
      IntegerLiteral ;

Digit
    = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" 
```

---

# 13. Examples

## Example 1

Source:

```txt
1 + 2
```

Result:

```txt
3
```

---

## Example 2

Source:

```txt
10 - 4 * 2
```

Result:

```txt
2
```

---

## Example 3

Source:

```txt
(10 - 4) * 2
```

Result:

```txt
12
```

---

## Example 4

Source:

```txt
5 * 2.5
```

Result:

```txt
7.5
```
---

## Example 5

Source:

```txt
// Monthly revenue
1000 + 250
```

Result:

```txt
1250
```

---

# 14. Out of Scope

The following features are explicitly excluded from Iteration 1:

- Variables
- Assignments
- Functions
- Strings
- Boolean values
- Arrays
- Objects
- Modules
- Classes
- Loops
- Conditional statements
- Type inference
- User-defined types

These features will be specified in future iterations.