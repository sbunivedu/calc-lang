#lang eopl

(provide parser evaluator)

; simple interpreter using define-datatype

(define-datatype calc-exp calc-exp?
  (lit-exp (var number?))
  (plus-exp (arg1 calc-exp?)
            (arg2 calc-exp?))
  (minus-exp (arg1 calc-exp?)
             (arg2 calc-exp?))
  (mult-exp (arg1 calc-exp?)
            (arg2 calc-exp?))
  (div-exp (arg1 calc-exp?)
           (arg2 calc-exp?)))

(define (parser exp)
  (cond
    ((number? exp) (lit-exp exp))
    ((equal? (cadr exp) '+) (plus-exp (parser (car exp))
                                      (parser (caddr exp))))
    ((equal? (cadr exp) '-) (minus-exp (parser (car exp))
                                       (parser (caddr exp))))
    ((equal? (cadr exp) '*) (mult-exp (parser (car exp))
                                      (parser (caddr exp))))
    ((equal? (cadr exp) '/) (div-exp (parser (car exp))
                                     (parser (caddr exp))))
    (else (eopl:error 'parser "Invalid concrete syntax: ~s" exp))))

(define (evaluator ast)
  (cases calc-exp ast
    (lit-exp (value) value)
    (plus-exp (arg1 arg2) (+ (evaluator arg1)
                             (evaluator arg2)))
    (minus-exp (arg1 arg2) (- (evaluator arg1)
                              (evaluator arg2)))
    (mult-exp (arg1 arg2) (* (evaluator arg1)
                             (evaluator arg2)))
    (div-exp (arg1 arg2) (/ (evaluator arg1)
                            (evaluator arg2)))))

; (evaluator (lit-exp 42))
; 42
; (evaluator (parser '((10 + 10) + 13)))
; 33
; (evaluator (parser '((100 * 100) * (26 / 2))))
; 130000
