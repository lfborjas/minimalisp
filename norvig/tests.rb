#Tests for the ruby translation of Peter Norvig's Lispy
#These are also his: http://norvig.com/lispy2.html

require './norvig.rb'
require 'test/unit'

module Test::Unit
    class TestCase
        alias_method :t?, :assert
        def f?(c)
            assert c == false
        end

        def self.must(name, &block)
            test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
            defined = instance_method(test_name) rescue false
            raise "#{test_name} is already defined in #{self}" if defined
            if block_given?
                define_method(test_name, &block)
            else
                define_method(test_name) do
                    flunk "No implementation provided for #{name}"
                end
            end
        end
    end
end

class SchemeTest < Test::Unit::TestCase
   def _!(exp)
       eval!(exp.to_sexp).to_lisp.to_atom
   end
   must "quote expressions" do
    t? _!("(quote (testing 1 (2.0) -3.14e159))") == :"(testing 1 (2.0) -3.14e+159)"
   end

   must "use predefined arithmetic methods" do
    t? _!("(+ 2 2)") == 4
    t? _!("(+ (* 2 100) (* 1 10))") == 210
   end

   must "branch well on conditional expressions" do
    t? _!("(if (> 6 5) (+ 1 1) (+ 2 2))") == 2
    t? _!("(if (< 6 5) (+ 1 1) (+ 2 2))") == 4
   end
   
   must "add bindings to the current environment" do
    _! "(define x 3)"
    t? _!("x") == 3
    t? _!("(+ x x)") == 6
   end

   must "evaluate consecutive expressions" do
    t? _!("(begin (define x 1) (set! x (+ x 1)) (+ x 1))") == 3
   end


   must "apply anonymous functions" do
    t? _!("((lambda (x) (+ x x)) 5)") == 10
   end

   must "add bindings to functions in the current environment" do
    _!("(define twice (lambda (x) (* 2 x)))")
    t? _!("(twice 5)") == 10
   end

   must "handle closures properly" do
    _!("(define compose (lambda (f g) (lambda (x) (f (g x)))))")
    t? _!("((compose list twice) 5)") == :"(10)"

    _!("(define repeat (lambda (f) (compose f f)))")
    t? _!("((repeat twice) 5)") == 20
    t? _!("((repeat (repeat twice)) 5)") == 80
   end

   must "handle recursive functions properly" do
    _!("(define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))")
    t? _!("(fact 3)") == 6
    t? _!("(fact 50)") == 30414093201713378043612608166064768844377641568960512000000000000
   end
    
   must "evaluate arguments to a function before applying it" do
    _!("(define abs (lambda (n) ((if (> n 0) + -) 0 n)))")
    t? _!("(list (abs -3) (abs 0) (abs 3))") == :"(3 0 3)"
   end

   must "handle complex closures" do
    _! %q|(define combine (lambda (f)
              (lambda (x y)
              (if (null? x) (quote ())
                  (f (list (car x) (car y))
                     ((combine f) (cdr x) (cdr y)))))))|
   
    _! "(define zip (combine cons))"
    t? _!("(zip (list 1 2 3 4) (list 5 6 7 8))") == :"((1 5) (2 6) (3 7) (4 8))"


    _! %q|(define riff-shuffle (lambda (deck) (begin
            (define take (lambda (n seq) (if (<= n 0) (quote ()) (cons (car seq) (take (- n 1) (cdr seq))))))
                (define drop (lambda (n seq) (if (<= n 0) seq (drop (- n 1) (cdr seq)))))
                    (define mid (lambda (seq) (/ (length seq) 2)))
                        ((combine append) (take (mid deck) deck) (drop (mid deck) deck)))))|
    t? _!("(riff-shuffle (list 1 2 3 4 5 6 7 8))") == :"(1 5 2 6 3 7 4 8)"
    t? _!("((repeat riff-shuffle) (list 1 2 3 4 5 6 7 8))") == :"(1 3 5 7 2 4 6 8)"
    t? _!("(riff-shuffle (riff-shuffle (riff-shuffle (list 1 2 3 4 5 6 7 8))))") == :"(1 2 3 4 5 6 7 8)"
   end

   must "Throw syntax errors" do
       wrong = lambda do |exp, msg|
           exc = assert_raise(SyntaxError){_!(exp)}
           t? exc == msg
       end

       wrong.call("()", "(): wrong length")
       wrong.call("(set! x)", "(set! x): wrong length")
       wrong.call "(define 3 4)", "(define 3 4): can define only a symbol"
       wrong.call "(quote 1 2)", "(quote 1 2): wrong length"
       wrong.call "(if 1 2 3 4)" , "(if 1 2 3 4): wrong length"
       wrong.call "(lambda 3 3)" , "(lambda 3 3): illegal lambda argument list"
       wrong.call "(lambda (x))" , "(lambda (x)): wrong length"
       wrong.call "(if (= 1 2) (define-macro a 'a) ", "(define-macro a (quote a)): define-macro only allowed at top level"   
   end

   must "check arguments" do
       _! "(define (twice x) (* 2 x))"
       t? _!("(twice 2)") == 4
       exc = assert_raise(TypeError) {_!("(twice 2 2)")}
       t? exc == "TypeError expected (x), given (2 2)"
   end

end
