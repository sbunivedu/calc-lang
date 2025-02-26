#lang eopl

(provide parser evaluator)

; simple interpreter that supports +,-,*, and /

(define (parser exp)
  (if (not (list? exp))
      (if (number? exp)
          (list 'lit-exp exp)
          (eopl:error 'parser
                      "Invalid number: ~s" exp))
      (cond
         ((> (length exp) 3)
          (eopl:error 'parser
                      "Invalid number of arguments: ~s" exp))
         ((eq? (cadr exp) '+)
          (list 'plus-exp
                (parser (car exp))
                (parser (caddr exp))))
         ((eq? (cadr exp) '-)
          (list 'minus-exp
                (parser (car exp))
                (parser (caddr exp))))
         ((eq? (cadr exp) '*)
          (list 'multiply-exp
                (parser (car exp))
                (parser (caddr exp))))
         ((eq? (cadr exp) '/)
          (list 'divide-exp
                (parser (car exp))
                (parser (caddr exp))))
         (else (eopl:error 'parser
                           "Invalid operator: ~s" exp)))))

(define (evaluator ast)
  (case (car ast)
    ((lit-exp) (cadr ast))
    ((plus-exp) (+ (evaluator (cadr ast))
                   (evaluator (caddr ast))))
    ((minus-exp) (- (evaluator (cadr ast))
                   (evaluator (caddr ast))))
    ((multiply-exp) (* (evaluator (cadr ast))
                   (evaluator (caddr ast))))
    ((divide-exp) (/ (evaluator (cadr ast))
                   (evaluator (caddr ast))))))

; (evaluator '(lit-exp 42))
; 42
; (evaluator (parser '((10 + 10) + 13)))
; 33
; (evaluator (parser '((100 * 100) * (26 / 2))))
; 130000
