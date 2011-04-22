;From SICP: the metacircular evaluator

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
      (else (apply (eval (car exp) env) (evlist (cdr exp) env))))))

;Up to this point, we only need to define lookup, evcond, evlist and apply
;Primitives: define, lambda, cond, number?, symbol?, eq?, cXr, list
;(list *could* be defined...)

;The number of the reserved words should be small

(define apply 
    (lambda (proc args)
        (cond 
            ((primitive? proc) (apply-primop proc args))
            ((eq? (car proc) 'closure)
                (eval (cadadr proc) 
                      (bind (caadr proc)
                            args
                            (caddr proc))))
            (else 'error))))

(define evlist
    (lambda (l env)
        (cond 
            ((eq? l '()) ())
            (else (cons (eval (car l) env)
                        (evlist (cdr l) env))))))

(define evcond
    (lambda (clauses env)
        (cond 
            ((eq? l '()) '())
            ((eq? (caar clauses) 'else) (eval (cadar clauses) env))
            ((not (eval (caar clauses) env))
                (evcond (cdr clauses) env))
            (else (eval (cadar clauses) env)))))

;bind adds two envs together:
(define bind
    (lambda (vars vals env)
        (cons (pair-up vars vals)
               env)))

;pairs up two equivalent lists:
(define pair-up
    (lambda (vars vals)
        (cond 
            ((eq? vars '())
                (cond ((eq? vals '()) '())
                      (else (error TOO-MANY-ARGS))))
            ((eq? vals '()) (error TOO-FEW-ARGS))
            (else
                (cons (cons (car vars) (car vals))
                      (pair-up (cdr vars)
                               (cdr vals)))))))

(define lookup
    (lambda (sym env)
        (cond ((eq? env '()) (error UNBOUND-VAR)
              (else 
                ((lambda (vcell)
                    (cond ((eq? vcell '()) (lookup sym (cdr env)))
                          (else (cdr vcell))))
                 (assq sym (car env))))))))

(define assq
    (lambda (sym alist)
        (cond ((eq? alist '()) '())
              ((eq? sym (caar alist)) (car alist))
              (else (assq sym (cdr alist))))))
