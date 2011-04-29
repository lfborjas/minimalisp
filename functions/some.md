!SLIDE 

#Algunas funciones

!SLIDE code

    @@@clojure

    (defn _and [a b]
      (cond a (cond b true true false)
            true false))
!SLIDE code

    @@@clj
    user=> (_and (= 'a 'a) (coll? '()))
    true
    (_and (= 'a b) (coll? '()))
    false

!SLIDE code

    @@@clojure
    (defn _or [a b]
      (cond a true
            b true
            true false))
    
!SLIDE code

    @@@clojure
    (defn _not [e]
      (cond e false true true))

!SLIDE code

    @@@clojure
    
    (defn _empty? [l]
      (_or (= l []) (= l '())))

!SLIDE code smaller
    
    @@@clojure
    (defn append [x y]
      (cond (_empty? x) y
            true (cons (first x) (append (rest x) y))))

!SLIDE code smaller

    @@@clojure
    (defn pair-up [x y]
      (cond (_and (_empty? x) (_empty? y)) '()
            (_and (coll? x) (coll? y)) 
              (cons (list (first x) (first y))
                    (pair-up (rest x) (rest y)))))

!SLIDE code smaller

    @@@clojure
    (defn lookup [sym env]
      (cond (empty? env) false
            (= (ffirst env) sym) (frfirst env)
            true (lookup sym (rest env))))

!SLIDE code smaller

    @@@clojure 
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
         

!SLIDE code

    @@@clj
    (_eval '((fn [x] (_not (coll? x))) 'a))

