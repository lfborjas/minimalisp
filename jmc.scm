; The Lisp defined in McCarthy's 1960 paper, translated into scheme.
; Assumes only quote, atom, eq, cons, car, cdr, cond.
; Originally from pg's article on the roots of lisp: http://www.paulgraham.com/rootsoflisp.html


;First, let's define the seven basic functions to see what's the fuzz about:

;Quote: returns the argument, shield against evaluation
(define (_quote x)
    x)

;Atom: a predicate to see whether something is atomic (e.g. null or not a list)

;define atom again to comply with common lisp boolean convention ('t for true and '() for false)
;which are, in scheme, #t and #f
(define (_atom? x)
    (cond 
        ((or (null? x) (atom? x)) 't)
        (else '())))

;eq: if two atoms are the same, or if both are the empty list

;again, wrap the normal eq function to mimic CL's convention ('t for true and '() for false)
(define (_eq? x y)
    (cond
        ((or (eq? x y) (and (null? x) (null? y))) 't)
        (else '())))

;cons: given an atom a and a list b, create a new list with a followed by the elements of b

;the following three taken from SICP lecture 2a.
;this function isn't ACTUALLY the whole thing, because it returns a procedure
;but does work to illustrate the concept of closures
(define (_cons a b)
    ;return a procedure that takes an index and returns the element in that index
    (lambda (pick)
        (cond ((= pick 1) a)
              ((= pick 2) b))))

;car: take the first element of a list

(define (_car l)
    (l 1))

;cdr: take the rest of a list (all but the first)

(define (_cdr l)
    (l 2))

;cond: given a list of (predicate, consequence), return the first consequence whose predicate evals to t
;note that this one differs from the cond macro in that we must put the pairs in a list...
(define (_cond pairs)
    (cond
        ((_null? pairs) '())
        ((_eq? (eval (caar pairs)) 't) (cadar pairs))
        (else (_cond (cdr pairs))))) 

;Alright, let's proceed to PG's interpretation of lisp

;first, a nice (and stupid?) macro to let us write function definitions in a common lisp/clojure style
;(from http://download.plt-scheme.org/doc/html/guide/pattern-macros.html#(part._define-syntax_and_syntax-rules))
(define-syntax-rule (defn name params body)
    (define name (lambda params body)))

;TODO: write the cond macro!

(defn _null?
   ;test whether an argument is the empty list
   [x]
    (_eq? x '()))

(defn _and
    ;returns t if both it's arguments do and () otherwise
    [a b]
    (cond 
        (a (cond (b 't) (else '())))
        (else '())))

(defn _not 
    ;returns t if the arg returns () and vice-versa
    [x]
    (cond 
        ((eq? x 't) '())
        (else 't)))

(defn _append
    ;takes two lists and returns their concatenation
    [x y]
    (cond 
        ((eq? (_null? x) 't) y)
        (else (cons (car x) (_append (cdr x) y)))))

(defn _zip
    ;(a.k.a pair) takes two lists of the same length 
    ;and pairs their respective elements
    [x y]
    (cond 
        ((and (null? x) (null? y)) '())
        ((and (not (atom? x)) (not (atom? y))) 
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
    ;take any LISP expression as a list and return it's return value
    [sexp environ]
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
    [c a]
    (cond 
        ((_eval (caar c) a) (_eval (cadar c) a))
        (else (evcon (cdr c) a))))

(defn evlis
    [m a]
    (cond 
        ((null? m) #f)
        (else (cons (_eval (car m) a)
                    (evlis (cdr m) a)))))
