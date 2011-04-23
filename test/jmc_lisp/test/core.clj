(ns jmc_lisp.test.core
  (:use [jmc_lisp.core] :reload)
  (:use [clojure.test]))

;Test stuff without an environ
(are [exp res] (= (eval! exp '()) res)
     '(quote x) 'x
     '(coll? 1) false
     '(coll? (1 2)) true
     '(= 2 2) true
     '(= 3 4) true
     '(first (quote (1 2 3))) 1
     '(rest (quote (1 2 3))) '(2 3)
     '(cons 1 (quote (2 3))) '(1 2 3)
     '(cond (eq? 2 2) true true false) true 
     '(cond (eq? 2 3) false true true) true
     '((fn [x] (coll? x)) 1) false
     '((def f (fn [x] (= x 2))) 2) true)

;Test stuff with an environ
(are [exp env res] (= (eval! exp env) res)
     '(empty? (quote ())) '((empty? (fn [l] (= l (quote ()))))) true
     '(empty? (quote (1 2))) '((empty? (fn [l] (= l (quote ()))))) false 
     '((def cadar 
             (fn [s] 
                     (first (cdar s)))) (quote (((1 2) 3) 4))) '((cdar (fn [l] (rest (first l))))) 3
     '((def append
              (fn [x y]
                      (cond 
                        (empty? x) y
                        true (cons (first x) (append (rest x) y)))))
         (quote (1 2 3)) (quote (4 5 6))) '((empty? (fn [l] (= l (quote ()))))) '(1 2 3 4 5 6)
     '((def maplist
              (fn [x p]
                      (cond 
                        (empty? x) (quote ())
                        true (cons (p x) (maplist (rest x) p))))) 
         (quote (1 2 3 2)) (quote (fn [e] (= e 2)))) '((empty? 
                                                           (fn [l]
                                                                   (= l (quote ()))))) '(false true false true)) 