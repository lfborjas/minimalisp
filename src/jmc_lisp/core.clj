(ns jmc_lisp.core
  (:use clojure.pprint)
  (:gen-class))

;Primitives:
;quote, coll?, =, first, rest, cons, cond
;Shortcuts:
;frest, ffirst, rrest, etc.
;(defn  f [args] body) for  (def f (fn [args] body))
;all predefined operations will be appended a -

;the first/rest combos: ffirst, frfirst, frest, frrest, frrfirst
(defn frfirst [l]
  (first (rest (first l))))

(defn frest [l]
  (first (rest l)))

(defn frrest [l]
  (first (rest (rest l))))

(defn frrfirst [l]
  (first (rest (rest (first l)))))

(defn rrest [l]
  (rest (rest l)))

;the functions:

(defn _and [a b]
  (cond a (cond b true true false)
        true false))

(defn _or [a b]
  (cond a true
        b true
        true false))

(defn _not [e]
  (cond e false true true))

(defn _empty? [l]
  (_or (= l []) (= l '())))

(defn append [x y]
  (cond (_empty? x) y
        true (cons (first x) (append (rest x) y))))
        
(defn pair-up [x y]
  (cond (_and (_empty? x) (_empty? y)) '()
        (_and (coll? x) (coll? y)) 
          (cons (list (first x) (first y))
                (pair-up (rest x) (rest y)))))

(defn lookup [sym env]
  (cond (empty? env) false
        (= (ffirst env) sym) (frfirst env)
        true (lookup sym (rest env))))

(declare _eval evcond evlist)

(defn _eval [exp env]
  ;(pprint [exp env])
  (cond 
    (_not (coll? exp)) (lookup exp env)
    (_not (coll? (first exp)))
      (cond 
        (= (first exp) 'quote) (frest exp)
        (= (first exp) 'coll?) (coll? (_eval (frest exp) env))
        (= (first exp) '=) (= (_eval (frest exp) env)
                              (_eval (frrest exp) env))
        (= (first exp) 'first) (first (_eval (frest exp) env))
        (= (first exp) 'rest)  (rest  (_eval (frest exp) env))
        (= (first exp) 'cons)  (cons  (_eval (frest exp) env)
                                      (_eval (frrest exp) env))
        (= (first exp) 'cond)  (evcond (rest exp) env)
        ;eval the body of the proc
        true (_eval (cons (lookup (first exp) env)
                          (rest exp))
                    env))
    (= (ffirst exp) 'def)
      (_eval (cons (frrfirst exp) (rest exp))
             (cons (list (frfirst exp) (first exp)) env))
    (= (ffirst exp) 'fn)
      (_eval (frrfirst exp)
             (append (pair-up (frfirst exp) 
                              (evlist (rest exp) env))
                     env))))

(defn evcond [clauses env]
  (cond 
    (_eval (first clauses) env)
      (_eval (frest clauses) env)
    true (evcond (rrest clauses) env)))

(defn evlist [m env]
  (cond 
    (_empty? m) '()
    true (cons (_eval (first m) env)
               (evlist (rest m) env))))

(defn- eval-with-env0 [exp]
  (prn (_eval exp '((true true) (false false)))))

(defn -main [& args]
  (clojure.main/repl :eval eval-with-env0 :prompt (fn [] (pr 'LISP>))))
