;Definición de scheme en scheme

; Operadores primitivos:

;symbol? y number?
;quote
;eq?
;car
;cdr
;cons
;cond

;Hablar de aplicación de funciones, definición

;Atajos: cXr y list

; Algunas funciones

(define null?
    (lambda (x) (eq? x '())))

(define and
    (lambda (x y)
        (cond (x (cond (y true) (true false)))
              (true false))))

(define not
    (lambda (x) 
        (cond 
            (x false)
            (true true))))

(define append
    (lambda (x y)
        (cond 
            ((null? x) y)
            (true (cons (car x)
                        (append (cdr x) y))))))

(define pair-up
    (lambda (vars vals)
        (cond 
            ((and (null? vars) (null? vals)) '())
            (true (cons (list (car vars) (car vals))
                        (pair-up (cdr vars) (cdr vals)))))))

(define lookup
    (lambda (var env)
        (cond 
            ((eq? (caar env) var) (cadar env))
            (true (lookup var (cdr env))))))

;The surprise:
;apply should eval eq, symbol?, number?, car, cdr and cons

(define eval
  (lambda (exp env)
    (cond 
      ((number? exp) exp)
      ((symbol? exp) (lookup exp env))
      ((eq? (car exp) 'quote) (cadr exp))
      ((eq? (car exp) 'lambda) 
        (list 'closure (cdr exp) env))
      ((eq? (car exp) 'cond) 
        (evcond (cdr exp) env))
      ((eq? (car exp 'define))
        (cons (list (cadr exp) (eval (caddr exp) env))
              env))
      (else (apply (eval (car exp) env) (evlist (cdr exp) env))))))


(define apply 
    (lambda (proc args)
        (cond 
            ((eq? (car proc) 'closure)
                (eval (cadadr proc);the body 
                      (cons
                            (pair-up (caadr proc);the arg list
                                     args)
                            (caddr proc)))))));the env
