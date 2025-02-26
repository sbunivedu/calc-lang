#lang eopl

(provide parser evaluator env)

; simple interpreter that supports n-ary functions

(define-datatype calc-exp calc-exp?
  (lit-exp (value number?))
  (var-exp (name symbol?))
  (app-exp (operator symbol?)
           (arg1 calc-exp?)
           (arg2 calc-exp?))
  (func-call-exp (func symbol?)
                 (arg1 calc-exp?)
                 (arg2 calc-exp?))
  (func-call-var-exp (func symbol?)
                     (args (list-of calc-exp?))))

; takes an s-expression representing our concrete syntax and returns an AST.

(define parser
  (lambda (exp)
    (cond ((number? exp) (lit-exp exp))
          ((symbol? exp) (var-exp exp))
          ((equal? (car exp) 'min)
           (func-call-exp 'min
                          (parser (cadr exp))
                          (parser (caddr exp))))
          ((equal? (car exp) 'max)
           (func-call-exp 'max
                          (parser (cadr exp))
                          (parser (caddr exp))))
          ((equal? (car exp) 'avg)
           (func-call-var-exp 'avg
                             (map parser (cdr exp))))
          ((equal? (car exp) 'sum)
           (func-call-var-exp 'sum
                              (map parser (cdr exp))))
          ((= (length exp) 3)
           (app-exp (cadr exp) (parser (car exp)) (parser (caddr exp))))
          (else (eopl:error 'parser "Invalid concrete syntax: ~s" exp)))))

(define evaluator
  (lambda (ast env)
    (cases calc-exp ast
      (lit-exp (value) value)
      (var-exp (name) (lookup name env))
      (app-exp (operator arg1 arg2)
               (cond
                 ((equal? operator '+)  (+ (evaluator arg1)
                                           (evaluator arg2)))
                 ((equal? operator '- ) (- (evaluator arg1)
                                           (evaluator arg2)))
                 ((equal? operator '* ) (* (evaluator arg1)
                                           (evaluator arg2)))
                 ((equal? operator '/ ) (/ (evaluator arg1)
                                           (evaluator arg2)))))
      (func-call-exp (func arg1 arg2)
                     (cond
                       ((equal? func 'min)
                        (min (evaluator arg1) (evaluator arg2)))
                       ((equal? func 'max)
                        (max (evaluator arg1) (evaluator arg2)))))
      (func-call-var-exp (func args)
                         (cond
                           ((equal? func 'avg)
                            (avg (map evaluator args)))
                           ((equal? func 'sum)
                            (sum (map evaluator args))))))))


(define avg
  (lambda (x)
    (/ (sum x)
       (length x))))

(define sum
  (lambda (x)
    (apply + x)))

(define (lookup name env)
  (let ((binding (assq name env)))
    (if binding
        (cadr binding)
        (eopl:error 'lookup "No such variable: ~a" name))))

(define env '((pi 3.141592653589793) (e 2.718281828459045)))

;(lookup 'pi env)
;3.141592653589793

;(evaluator (parser 'pi) env)
;3.141592653589793

;(evaluator (parser '(pi * (2 * 2))) env)
;12.5663706143592