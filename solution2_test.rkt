#lang racket

(require rackunit)
(require "solution2.rkt")

(check-equal?
 (evaluator (parser 42))
 42)

(check-equal?
 (evaluator (parser '((10 + 10) + 13)))
 33)

(check-equal?
 (evaluator (parser '((100 * 100) * (26 / 2))))
 130000)
