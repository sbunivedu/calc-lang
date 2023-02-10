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

### Parser: concrete syntax to Abstract Syntax Tree (AST)
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




