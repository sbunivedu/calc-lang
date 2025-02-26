#lang eopl

(provide parser evaluator)

; simple interpreter that supports n-ary functions

(define-datatype calc-exp calc-exp?
  (lit-exp (var number?))
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
  (lambda (ast)
    (cases calc-exp ast
      (lit-exp (value) value)
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

;(require racket/trace)
;(trace parser)

; (evaluator (parser '(max 10 2)))
; 10
; (evaluator (parser '(min 10 2)))
; 2
; (evaluator (parser '(sum 10 2 4 5 6)))
; 27
; (evaluator (parser '(avg 10 2 4 5 6)))
; 5 2/5
; (evaluator (parser '(avg 1 (2 + 3))))
; 3
; (evaluator (parser '(avg 1 (max 2 3))))
; 2
; (evaluator (parser '(avg 1 (avg 2 3))))
; 1 3/4
; (evaluator (parser '((avg 1 3) + (avg 2 4))))
; 5
