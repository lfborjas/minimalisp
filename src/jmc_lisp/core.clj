(ns jmc_lisp.core
  (:use clojure.pprint)
  (:require clojure.main)
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

(defn frfrest [l]
  (-> l rest first rest first))

(defn ffrest [l]
  (-> l rest first first))


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
          (cons (cons (first x) (cons (first y) '()))
                (pair-up (rest x) (rest y)))))

(defn lookup [sym env]
  (cond (empty? env) false
        (= (ffirst env) sym) (frfirst env)
        true (lookup sym (rest env))))

(declare _eval evcond evlist _apply)

(defn _eval [exp env]
    (cond 
      (_not (coll? exp)) (lookup exp env)
      (= (first exp) 'quote) (frest exp)
      (= (first exp) 'coll?) (coll? (_eval (frest exp) env))
      (= (first exp) '=) (= (_eval (frest exp) env)
                            (_eval (frrest exp) env))
      (= (first exp) 'first) (first (_eval (frest exp) env))
      (= (first exp) 'rest)  (rest  (_eval (frest exp) env))
      (= (first exp) 'cons)  (cons  (_eval (frest exp) env)
                                    (_eval (frrest exp) env))
      (= (first exp) 'cond)  (evcond (rest exp) env)
      (= (first exp) 'fn )  (list 'closure (rest exp) env)
      true (_apply (_eval  (first exp) env)
                   (evlist (rest  exp) env))))

(defn _apply [proc args]
  (cond
    (= (first proc) 'closure) 
      (_eval 
        (frfrest proc) ;body of the procedure
        (append ;build a new environment:
          (pair-up (ffrest proc) args) ;map the formal arguments to the parameters
          (frrest proc))) ;the environment that this proc was closed upon
    true 'unrecognized-expression))


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

;;;;;;;;; NON ESSENTIAL STUFF ;;;;;;;;;
;global variable, it turns out that clojure is purely functional and 
;globals are REALLY hard to achieve, but that's good, I guess.
(def *env0* (atom '((true true) (false false))))

(defn- eval-with-env0 [exp]
    (cond 
      ;this could go above, but I don't want to fuck up the purity of eval
      (and (coll? exp) (= (first exp) 'def)) (swap! *env0* conj (rest exp))
      :else (_eval exp @*env0*)))

(defn -main [& args]
  (clojure.main/repl :eval eval-with-env0 :prompt (fn [] (pr 'LISP>))))

