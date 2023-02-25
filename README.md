# Calculator Language Project

## Objectives
* Create a language from scratch
* Write parser and evaluator
* Use the `define-datatype` interface to define recursive structure
* Add predefined variables
* Add variable assignments
* Add functions with closure
* Allow recursively defined functions

## Introduction
When we talk about a programming language, we often refer to its form, or syntax. For example, in C or Java, you might have a function that looks like:
```c
int plus_one(int n) {
    return n + 1;
}
```
We will refer to this kind of syntax as **concrete syntax**. Concrete syntax is what one actually types to program in a particular language. However, to make processing a language easier, the first step in creating a programming language is to convert concrete syntax into **abstract syntax**. In fact, we will **convert**, or **parse**, concrete syntax into an **Abstract Syntax Tree** (AST). This is a "tree" in that it is a recursive data structure representing a program.

## Parser: concrete syntax to Abstract Syntax Tree (AST)
We will write a small, but complete, Calculator Language. Your language should be able to at least **add**, **subtract**, **divide**, and **multiple**. The language should use **infix** notation, as per these examples. In addition, your language should allow arbitrary **recursive** expressions.

Typically, we will use strings to represent concrete syntax. So the above example might look like:
```
(define program "
    int plus_one(int n) {
        return n + 1;
    }")
```

However, to start out we will use **Scheme Expressions**(s-expressions) to represent programs instead of strings. These will initially look just like the simple `infix` expressions from the homework.

So, our first goal is to write a parser that will take an expression such as `'(1 + 2)` and turn it into an AST.

To begin, we will have just two kinds of expressions in our Calc language:
1. numbers, which will be tagged as literals, **lit-exp**
2. addition expressions, which will be tagged as **plus-exp**

Concrete syntax:
```{2,4}
<expression> ::= <number>
             lit-exp (n)
             ::= (<expression> + <expression>)
             plus-exp (arg1 arg2)
```

`lit-exp` will be a list composed of the symbol `lit-exp` followed by the number, like:
```
'(lit-exp 34)
'(lit-exp -1)
'(lit-exp 12133456)
```

A `plus-exp` will be a list composed of the symbol `plus-exp` followed by two Calc expressions, like:
```
'(plus-exp (lit-exp 1) (lit-exp 2))
'(plus-exp (lit-exp 1)
           (plus-exp (lit-exp 2) (lit-exp 3)))
```

`lit-exp` will be a list composed of the symbol `lit-exp` followed by the number, like:
```
'(lit-exp 34)
'(lit-exp -1)
'(lit-exp 12133456)
```

A `plus-exp` will be a list composed of the symbol `plus-exp` followed by two Calc expressions, like:
```
'(plus-exp (lit-exp 1) (lit-exp 2))
'(plus-exp (lit-exp 1)
           (plus-exp (lit-exp 2) (lit-exp 3)))
```

Our first goal is to write a parser that takes s-expression Calc representations and turn them into AST's:
```
> (parser '(1 + 2))
(plus-exp (lit-exp 1) (lit-exp 2))
```

The parser could look as follows:
```scheme
#lang scheme

(define (parser exp)
  (cond
    ((number? exp) (list 'lit-exp exp))
    ((equal? (cadr exp) '+)
     (list 'plus-exp
           (parser (car exp))
           (parser (caddr exp))))
    (else (error "Invalid concrete syntax: " exp))))
```

```
> (parser 42)
(lit-exp 42)
> (parser '(1 + 2))
(plus-exp (lit-exp 1) (lit-exp 2))
> (parser '(1 + ((2 + 3) + 4)))
(plus-exp (lit-exp 1) (plus-exp (plus-exp (lit-exp 2) (lit-exp 3)) (lit-exp 4)))
> (parser '(100 ^ 2))
Invalid concrete syntax:  (100 ^ 2)
```

### Exercise 1
Extend the parser to include the ability to parse minus, multiply, and divide concrete syntax. Extensively test it to make sure that it works for all valid input, and fails on non-valid input.

## Evaluator: interpret AST
In Part 2 we will design and build evaluator that will take ASTs and evaluate/interpret them. That is, we will interpret the AST into their calculated form. The result of the evaluator at this point will always be a number, because both of our forms, `plus-exp` and `lit-exp` both evaluate to numbers.
```scheme
(define (evaluator ast)
  (case (car ast)
    ((lit-exp) (cadr ast))
    ((plus-exp) (+ (evaluator (cadr ast))
                   (evaluator (caddr ast))))))
```

```
> (evaluator (parser '(3 + 2)))
5
> (evaluator (parser '2))
2
```

Note that this implementation uses `case` syntactic form in Scheme, which works similar to "switch case" statement in Java, and is more readable than the following implementation using just `cond`:
```scheme
(define (evaluator ast)
  (cond
    ((equal? (car ast) 'lit-exp) (cadr ast))
    ((equal? (car ast) 'plus-exp)
     (+ (evaluator (cadr ast))
        (evaluator (caddr ast))))))
```

### Excercise 2
Extend this evaluator to evaluate multiple, divide, and minus. Extensively test your code to make sure that it works correctly. Errors such as divide-by-zero should produce "run time" errors. Errors such as `(1 + +)`, `(+ 1 2)` and `(1 + 2 + 3)` should produce syntax errors.

## Define-datatype

Things get a bit messy with the `cars` and `cdrs` in the above evaluator. We introduce [define-datatype](https://docs.racket-lang.org/eopl/index.html?q=define-datatype#%28form._%28%28lib._eopl%2Feopl..rkt%29._define-datatype%29%29) to make these datatypes easier to deal with by giving them named-parts.

`define-datatype` is a special form used to create recursive data structures. It takes the form:
```
(define-datatype NAME TEST?
  (variant1
     (field-id predicate-expr))
  (variant2
     (field-id predicate-expr))
… )
```

For example, we can define `calc-exp` as being composed of `lit-exp` and `plus-exp`:
```scheme
(define-datatype calc-exp calc-exp?
  (lit-exp (var number?))
  (plus-exp (arg1 calc-exp?)
            (arg2 calc-exp?)))
```

The above code automatically defines the following:
| name | meaning |
| :--- | :------ |
| calc-exp | a named type |
| calc-exp? | a predicate that determines if a value belongs to the named type |
| lit-exp | a variant type name and a constructor/procedure for creating values belonging to the variant |
| plus-exp | same as above |

```
> (list calc-exp? lit-exp plus-exp)
(#<procedure:calc-exp?> #<procedure:lit-exp> #<procedure:plus-exp>)
> (lit-exp 1)
#(struct:lit-exp 1)
> (lit-exp 'a)
lit-exp: bad value for var field: a
> (calc-exp? (lit-exp 42))
#t
> (plus-exp (lit-exp 1) (lit-exp 2))
#(struct:plus-exp #(struct:lit-exp 1) #(struct:lit-exp 2))
```

We can now clean up the parser and evaluator by using the new datatypes. Here is the base evaluator:
```scheme
(define-datatype calc-exp calc-exp?
  (lit-exp (var number?))
  (plus-exp (arg1 calc-exp?)
            (arg2 calc-exp?)))

(define (parser exp)
  (cond
    ((number? exp) (lit-exp exp))
    ((equal? (cadr exp) '+)
     (plus-exp
      (parser (car exp))
      (parser (caddr exp))))
    (else (eopl:error 'parser "Invalid concrete syntax: ~s" exp))))

(define (evaluator ast)
  (cases calc-exp ast
    (lit-exp (value) value)
    (plus-exp (arg1 arg2) (+ (evaluator arg1)
                             (evaluator arg2)))))
```
Note that `cases` branches on the datatype instance produced by `ast`, which must be an instance of the specified datatype-id (e.g. `calc-exp`) that is defined with `define-datatype`.

```
> (evaluator (lit-exp 42))
42
> (evaluator (parser '((10 + 10) + 13)))
33
> (evaluator (parser '((100 * 100) * (26 / 2))))
130000
```

### Excercise 3
Rewrite the parser and evaluator to use `define-datatype`. Test them both thoroughly to make sure that all correct versions work, and that incorrect forms fail.

### Excercise 4
Refine your grammar so that all infix operators are treated as one expression type, rather than 4 different ones. For example, instead of having `plus-exp`, `minus-exp`, and etc., you will now have something like `app-exp` ("application expression"). You'll need to add another field to your new expression to store the operation symbol (e.g., `+`, `-`, `*`, or `/`). Add other mathematical operators to make your Calculator Language more useful.

You can test whether an expression represents an infix binary operation as follows: if `(= 3 (length '(1 + (2 * 3))))` return true, `'(1 + (2 * 3))` must represent a binary operation with an operator and two operands. We know if the length of the list is not 3 it has to be a syntax error. We can let input such as `'(1 2 3)` pass because it will eventually cause a runtime error.

You can turn a symbol into a procedure as follows:
```
> ((eval '+) 1 2 3)
6
> ((eval '*) 3 4)
12
```
