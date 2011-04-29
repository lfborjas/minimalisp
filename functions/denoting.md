!SLIDE 

#Funciones

!SLIDE bullets

* Podíamos aplicar una función
* `(cons 'a '(b c d))`
* ¿Cómo crearíamos las nuestras?

!SLIDE 

# `((fn [p1 p2 ...] exp) a1 a2 ...)`

!SLIDE code

    @@@clj
    user=> ((fn [p1 p2 p3] 'exp) a1 a2 a3)
    user=> ((fn [x] (cons x '(b c))) 'a)
    (a b c)
    user=> ((fn [x y] (cons x y)) 'a '(b c))
    (a b c)
    user=> ((fn [f] (f '(b c))) (fn [x] (cons 'a x)))
    (a b c)

!SLIDE bullets 

# `(def nombre (fn [p1 p2] ('algo-con-nombre)))`

* Con `def` podemos hacer que una función se 
  pueda referir a sí misma

!SLIDE code small
    
    @@@clojure
    ((def _last 
        (fn [l] 
            (cond (= (rest l) '()) (first l)
                  true (_last (rest l))))) '(a b c))
    ;devuelve c

!SLIDE code small
    
    @@@clojure
    ;de atajo, digamos que (def f (fn [] exp))
    ;sea: (defn f [] exp)
    ((defn _last [l]
            (cond (= (rest l) '()) (first l)
                  true (_last (rest l)))) '(a b c))
    ;devuelve c

!SLIDE 

#Abreviaciones

!SLIDE code

    @@@clojure
    ;en vez de
    (first (first '(a b c)))
    ;digamos
    (ffirst '(a b c))
    ;o
    (first (rest '(a b c)))
    ;mejor
    (frest '(a b c))

!SLIDE code

    @@@clojure
    ;en vez de 
    (cons 'a (cons 'b (cons 'c '())))
    ;digamos
    (list 'a 'b 'c)


