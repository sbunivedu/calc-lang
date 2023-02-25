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

## N-nary operators

We will add the following functions to our language by adding them to the grammar. `min`, `max` should each take two arguments and return the `min` and `max` (respectively) of the two numbers. The concrete syntax of min and max should be:
```
(min 1 2)
(max 3 7)
```
And they should parse to AST that looks like:
```
(func-call-exp min calc-exp calc-exp)
(func-call-exp max calc-exp calc-exp)
```
When evaluated, they will give the `min` or the `max` of the two arguments.

### Exercise 5
Add the functions avg and sum which can take any number of expressions, and compute the average.
```
(sum 1 2 3 6) => 12
(avg 1 2 3 6) => 3
```

Here is one way of defining `func-call-var-exp`, a datatype with variable args:
```
(define-datatype calc-exp2 calc-exp2?
  (func-call-var-exp
   (func symbol?)
   (args (list-of number?))))

> (func-call-var-exp 'sum '(1 2 3))
#(struct:func-call-var-exp sum (1 2 3))
> (evaluator (parser '(max 10 2)))
10
> (evaluator (parser '(min 10 2)))
2
> (evaluator (parser '(avg 10 2 4 5 6)))
525
```

The `list-of` function takes a function `f` and returns a function, which takes a list of items and applies `f` to each. If `(f item)` is true for all items, then the function returns `#t`, otherwise `#f`. The `eopl` language implements this `list-of` function, which can be written as follows:
```
(define (list-of pred)
  (lambda (lst)
    (or (null? lst)
        (and (pair? lst)
             (pred (car lst))
             ((list-of pred) (cdr lst))))))

> ((list-of number?) '(1 2 3))
#t
> ((list-of number?) '(1 2 a))
#f
> ((list-of symbol?) '(1 2 a))
#f
> ((list-of symbol?) '(a b c))
#t
```

We can define some helper functions that we will need in the evaluator: `avg` and `sum`:

```
(define avg
  (lambda (x)
    (/ (sum x)
       (length x))))

(define sum
  (lambda (x)
    (apply + x)))

> (sum '(1 2 3 4))
10
> (avg '(1 2 3))
2
> (avg (list 1 2 3 4))
2 1/2
> (apply + '(1 2 3))
6
> (apply = '(1 1))
#t
> (apply (lambda (x y) (+ x y)) '(1 2))
3
```
### Predefined variables
We will pre-define `pi` as 3.141592653589793, and `e` as 2.718281828459045.

In order to use variables, you will need to pass in the environment to the evaluate function (and everywhere you call evaluate). We will use an association list as the environment. So, an environment will be defined and used like so:

```
(define env '((pi 3.141592653589793)
              (e  2.718281828459045)))

> (assq 'pi env)
(pi 3.141592653589793)
Note: "assq" returns the first element in "env" whose car is "pi".

> (assq 'c env)
#f
```

Change the evaluate function to take an additional argument, the environment. You will need to add `var-exp` to the `define-datatype`, and be able to parse and evaluate the variables. It should then work as follows:
```
> (evaluate (parser 'pi) env)
3.141592653589793
```

Finally, use your new language to compute something useful. For example, what is the area of a circle of radius 2 feet?
```
> (evaluate (parser '(pi * (2 * 2))) env)
12.5663706143592
```

Now, we define an environment and a utility function to make testing easy:
```
(define (lookup name env)
  (let ((binding (assq name env)))
    (if binding
        (cadr binding)
        (eopl:error 'lookup "No such variable: ~a" name))))

(define env '((pi 3.141592653589793) (e 2.718281828459045)))
> (lookup 'pi env)
3.141592653589793
> (lookup 'c env)
lookup: No such variable: c
```

Note that `assq` is used to search for a name in a list of `(name value)` pairs.

Finally, in the evaluator, we evaluate the AST:
```
(define evaluator
  (lambda (ast env)
...

(define env (list (list 'pi 3.141592653589793)
                  (list 'e  2.718281828459045)))

(define (calc exp)
  (evaluator (parser exp) env))

(define (test exp)
  (printf "~a -> ~a~%" exp (calc exp env)))
```

Now update your evaluator to use predefined variables in the environment. Your language needs to support the following operations: `+`, `*`, `min`, `max`, `avg`, and `sum` and evaluate them using the current environment.

The beginning of our calculator language looks very good! It can do at least as much as a good calculator, maybe more: it has infix operators, some specific functions, and variables. But the implementation of the different functions and operators was pretty messy. The way that we had to write the parser was a bit limiting. For example, we might have some ambiguity in the future:
```
In  [A]: (new-function + 34)
In  [B]: (min + 23)
In  [C]: (34 f 56)
```
In A, our parser may find that to be addition, when we really meant it to be an application of the new-function.

In B, we can't have a variable named `min` or it would throw off our parser.

In C, we can't have a variable `f` bound to `+`, because our parser wouldn't know that that is a `plus-exp`.

Perhaps we should consider a concrete syntax like Scheme's. Then all of the functions would appear in the initial position. Let's leave that for the moment. In fact, let's remove all of the applications of functions, and think about what it would take for the user to be able to write their own functions.

As a warm up, let's add `if-exp` to a stripped-down parser/evaluator.

## If expression
We know that an `if-exp` in Scheme is a "special form"... it short-circuits evaluation of the elements, not evaluating the branch that it doesn't need to. Let's define what the parser and evaluator should give us:

```
> (parser '(if 1 2 3))
(if-exp (lit-exp 1) (lit-exp 2) (lit-exp 3))
> (calc '(if 1 2 3))
2
> (calc '(if 0 2 3))
3
```

Let us pare-down the datatype to the bare minimum to focus on new forms:
```
(define-datatype calc-exp calc-exp?
  (lit-exp
   (value number?))
  (var-exp
   (name symbol?))
  (if-exp
   (test-exp calc-exp?)
   (then-exp calc-exp?)
   (else-exp calc-exp?)))
```

The parser is simply:
```
(define (parser exp)
  (cond
    ((symbol? exp) (var-exp exp))
    ((number? exp) (lit-exp exp))
    ((eq? (car exp) 'if) (if-exp (parser (cadr exp))
                                 (parser (caddr exp))
                                 (parser (cadddr exp))))))

> (parser '(if 1 2 3))
#(struct:if-exp #(struct:lit-exp 1) #(struct:lit-exp 2) #(struct:lit-exp 3))
```

Test out the parser to make sure it is recursively well-defined.

To use our new `if-exp`, we need to have the ability to test whether an expression is true. We could introduce a boolean type. However, for the moment let's just use numbers to represent booleans. We define false to be 0; anything else will be true:
```
(define (true? v)
  (not (= v 0)))

> (true? 1)
#t
> (true? 0)
#f
> (true? 42)
#t
```

Our evaluator handling if-exp:
```
(define (evaluator ast env)
  (cases calc-exp ast
    (lit-exp (value) value)
    (var-exp (name) (lookup name env))
    (if-exp (test-exp then-exp else-exp)
            (if (true? (evaluator test-exp env))
                (evaluator then-exp env)
                (evaluator else-exp env)))))


> (calc '(if 1 2 3))
2
> (calc '(if 0 2 3))
3
> (test '(if 0 2 3))
(if 0 2 3) -> 3
```

Extensively test `if-exp` with recursive expressions.
