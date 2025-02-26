#lang eopl

(provide parser evaluator)

; simple interpreter that uses define-datatype and "app-exp" for all infix operators

(define-datatype calc-exp calc-exp?
  (lit-exp (var number?))
  (app-exp (operator symbol?)
           (arg1 calc-exp?)
           (arg2 calc-exp?)))

(define (parser exp)
  (cond
    ((number? exp) (lit-exp exp))
    ((= 3 (length exp))
     (app-exp (cadr exp)
              (parser (car exp))
              (parser (caddr exp))))
    (else (eopl:error 'parser "Invalid concrete syntax: ~s" exp))))

(define (evaluator ast)
  (cases calc-exp ast
    (lit-exp (value) value)
    (app-exp (operator arg1 arg2)
             ((eval operator) (evaluator arg1)
                              (evaluator arg2)))))

; (evaluator (parser '((10 + 10) + 13)))
; 33
; (evaluator (parser '((100 * 100) * (26 / 2))))
; 130000
