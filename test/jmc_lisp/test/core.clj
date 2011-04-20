(ns jmc_lisp.test.core
  (:use [jmc_lisp.core] :reload)
  (:use [clojure.test]))

;Test stuff without an environ
(are [exp res] (= (eval! exp '()) res)
     '(quote x) 'x
     '(atom? 1) true
     '(atom? (1 2)) false
     '(eq? 2 2) true
     '(eq? 3 4) true
     '(car (quote (1 2 3))) 1
     '(cdr (quote (1 2 3))) '(2 3)
     '(cons 1 (quote (2 3))) '(1 2 3)
     '(cond ((eq? 2 2) true) (true false)) true 
     '(cond ((eq? 2 3) false) (true true)) true
     '((lambda (x) (atom? x)) 1) true
     '((label l (lambda (x) (eq? x 2))) 2) true)

;Test stuff with an environ
(are [exp env res] (= (eval! exp env) res)
     '(null? (quote ())) '((null? (lambda (l) (eq? l (quote ()))))) true
     '(null? (quote (1 2))) '((null? (lambda (l) (eq? l (quote ()))))) false 
     '((label cadar 
             (lambda (s) 
                     (car (cdar s)))) (quote (((1 2) 3) 4))) '((cdar (lambda (l) (cdr (car l))))) 3
     '((label append
              (lambda (x y)
                      (cond 
                        ((null? x) y)
                        (true (cons (car x) (append (cdr x) y))))))
         (quote (1 2 3)) (quote (4 5 6))) '((null? (lambda (l) (eq? l (quote ()))))) '(1 2 3 4 5 6)
     '((label maplist
              (lambda (x p)
                      (cond 
                        ((null? x) (quote ()))
                        (true (cons (p x) (maplist (cdr x) p)))))) 
         (quote (1 2 3 2)) (quote (lambda (e) (eq? e 2)))) '((null? 
                                                                   (lambda (l)
                                                                           (eq? l (quote ()))))) '(false true false true)) 






