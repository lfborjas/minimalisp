; The Lisp defined in McCarthy's 1960 paper, translated into scheme.
; Assumes only quote, atom, eq, cons, car, cdr, cond. And list and cXr
; Originally from pg's article on the roots of lisp: http://www.paulgraham.com/rootsoflisp.html

;first, a nice (and stupid?) macro to let us write function definitions in a CL/clojure style
;(from http://download.plt-scheme.org/doc/html/guide/pattern-macros.html#(part._define-syntax_and_syntax-rules))
(define-syntax-rule (defn name params body)
    (define name (lambda params body)))

(defn _null?
   ;test whether an argument is the empty list
   [x]
    (eq? x '()))

(defn _and
    ;returns #t if both it's arguments do and #f otherwise
    [a b]
    (cond 
        (a (cond (b #t) (else #f)))
        (else #f)))

(defn _not 
    ;returns #t if the arg returns #f and vice-versa
    [x]
    (cond 
        (x  #f)
        (else #t)))

(defn _append
    ;takes two lists and returns their concatenation
    [x y]
    (cond 
        ((_null? x) y)
        (else (cons (car x) (_append (cdr x) y)))))

(defn _zip
    ;(a.k.a pair) takes two lists of the same length 
    ;and pairs their respective elements
    [x y]
    (cond 
        ((_and (null? x) (null? y)) '())
        ((_and (_not (atom? x)) (_not (atom? y))) 
            (cons (list (car x) (car y))
                  (_zip (cdr x) (cdr y)))))) 

(define _pair _zip)

(defn _assoc
    ;takes an atom k and a list l of a form created by pair
    ;and returns the element associated to k in l (the second in the tuple)
    [k l]
    (cond 
        ((eq? (caar l) k) (cadar l))
        (else (_assoc k (cdr l)))))

(defn _eval
    ;OH MY BATMAN! This is the heart of a lisp, HERE are the seven predefined functions
    ;and this, in turn, depends, on the above functions. 
    ;LISP CAN BE WRITTEN IN ITSELF!
    ;take any LISP expression as a list and return it's return value
    ;e is the sexp
    ;a is the environment (empty by default)
    (e [a '()])
    (cond 
        ((atom? e) (_assoc e a)) ;look up the atom in the environment
        ((atom? (car e)) ;deal with functions and macros
            (cond 
                ;first, the seven predefined functions
                ((eq? (car e) 'quote) (cadr 'e)) ; (quote 1) => 1
                ((eq? (car e) 'atom?) (atom? (_eval (cadr e) a))) ;define atom?
                ((eq? (car e) 'eq?)   (eq?   (_eval (cadr e) a)
                                             (_eval (caddr e) a)))
                ((eq? (car e) 'car)   (car   (_eval (cadr e) a)))
                ((eq? (car e) 'cdr)   (cdr   (_eval (cadr e) a)))
                ((eq? (car e) 'cons)  (cons  (_eval (cadr e) a)
                                             (_eval (caddr e) a)))
                ((eq? (car e) 'cond)  (evcon (cdr e) a))
                ;else, eval a user defined function:
                (else 
                    (_eval (cons (_assoc (car e) a)
                                 (cdr e))
                           a))))
        ;now, to function definition macros:
        ((eq? (caar e) 'label)
             (_eval (cons (caddar e) (cdr e))
                    (cons (list (cadar e) (car e) a))))
        ((eq? (caar e) 'lambda)
             (_eval (caddar e)
                    (_append (_zip (cadar e) (evlis (cdr e) a)) a)))))

(defn evcon
    ;evaluate a condition
    [c a]
    (cond 
        ((_eval (caar c) a) (_eval (cadar c) a))
        (else (evcon (cdr c) a))))

(defn evlis
    ;bind an environment to an anonymous function
    [m a]
    (cond 
        ((_null? m) #f)
        (else (cons (_eval (car m) a)
                    (evlis (cdr m) a)))))
