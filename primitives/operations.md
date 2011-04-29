!SLIDE

#Imaginemos que tenemos que simbolizar la computación

!SLIDE bullets
##Expresiones

* Tenés símbolos 
* Y listas (colecciones) de símbolos

!SLIDE code

    @@@clojure
    zalgo ;es un símbolo (y esto, un comentario)
    () ; lista
    [] ; lista
    (a b c) 
    [1 2 3]  
    (a b (c d))

!SLIDE bullets

##Toda cosa interesante pasa dentro de las listas

* El primer elemento se considera una *operación*
* Los demás, los *operandos*
* El valor de la expresión, si es una lista, es
  la  operación aplicada a los operandos

!SLIDE code

    @@@clj
    user=> (+ 1 2 3 4)
    10
    user=> (+ (* 2 3) (/ 10 2))
    11


!SLIDE 

#Siete operaciones básicas

!SLIDE code 
## 1. quote: Devuelve su argumento 

    @@@clj
    user=> (quote x)
    x
    user=> (quote (a b c))
    (a b c)
    user=> '(a b c)
    (a b c)

!SLIDE code 

##2. coll? : si el argumento es una colección

    @@@clj
    user=> (coll? 1)
    false
    user=> (coll? '(1 2 3))
    true
    user=> (coll? [1 2 3])
    true

!SLIDE code

    @@@clj
    user=> (coll? (coll? 'x))
    ???
    user=> (coll? '(coll? 'x))
    ???

!SLIDE code

    @@@clj
    user=> (coll? (coll? 'x))
    false
    user=> (coll? '(coll? 'x))
    true

!SLIDE code

##3. = : si sus argumentos valen lo mismo

    @@@clj
    user=> (= 1 2)
    false
    user=> (= 'a 'a)
    true    

!SLIDE code 
##4. first: primer elemento de la coll

    @@@clj
    user=> (first '(a b c))
    a
    user=> (first '[c b a])
    c

!SLIDE code 
##5. rest : la "cola" de la coll

    @@@clj
    user=> (rest '(a b c))
    (b c)
    user=> (rest '[c b a])
    (b a)


!SLIDE code
##6. cons: crea una lista con cabeza y cola

    @@@clj
    user=> (cons 'a '(b c d))
    (a b c d)
    user=> (cons 'a (cons 'b (cons 'c '())))
    (a b c)

!SLIDE bullets
##7. cond

* Recibe pares de expresiones, si la primera del par evalúa a verdadero
  devuelve la segunda del par; si no, pasa al siguiente par

!SLIDE code smaller

    @@@clj
    user=> (cond (= 'a 'b) 'primero (coll? '(c d)) 'segundo)
    segundo
    user=> (cond false 'falso! (coll? 'x) '?  true 'verdadero!)
    verdadero!


