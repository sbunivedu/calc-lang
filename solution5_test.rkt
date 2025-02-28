#lang racket

(require rackunit)
(require "solution5.rkt")

(check-equal?
 (evaluator (parser 'pi) env)
 3.141592653589793)

(check-equal?
 (evaluator (parser '(pi * (2 * 2))) env)
 12.566370614359172)
