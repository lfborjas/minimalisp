# The Lisp defined in McCarthy's 1960 paper, translated into ruby
# based on this article by Paul Graham: http://www.paulgraham.com/rootsoflisp.html
class Array
    alias :pair :zip
    alias :append :concat

    #to avoid stack overflow while testing, 'cause it could be called twice
    alias_method(:_assoc, :assoc) unless method_defined? :_assoc
    def assoc(k)
        return k if k.is_a? Fixnum or [:t, :f].include? k
        _assoc(k).cadr unless _assoc(k).nil?
    end

end

class Object
    def quote
        self
    end

    def to_atom
        Integer(self) rescue Float(self) rescue to_sym
    end

    def to_lisp
        self.is_a?(Array) ? "(#{self.collect{|v| v.to_lisp}.join(' ')})" : self.to_s
    end

    def atom?
        return true if self.is_a? String
        !self.respond_to? :each
    end

    def cons(l)
        [self] + l
    end

    def eq?(o)
        return self.to_sym.eql?(o) if o.is_a? Symbol
        eql? o
    end

    def car
        self.respond_to?(:[]) ? self[0] : self
    end

    def cdr
        self.respond_to?(:slice) ? self.slice(1..-1) : self
    end


    def method_missing(m, *args, &block)
        if m.to_s =~ /c[ad]+r/
            rval = self
            m.to_s.reverse.slice(1..-2).each_char do |f|
                rval = rval.send(f == 'a' ? :car : :cdr) 
            end
            rval
        end
    end
    
    def _eval(a=[])
        #it self it's an atom, just resolve it in the environment
        if atom? then a.assoc(self)

        #now, function applications
        elsif car.atom? 
            if    car.eq? :quote then cadr
            elsif car.eq? :atom? then cadr._eval(a).atom?
            elsif car.eq? :eq?   then cadr._eval(a).eql? caddr._eval(a)  
            elsif car.eq? :car   then cadr._eval(a).car
            elsif car.eq? :cdr   then cadr._eval(a).cdr
            elsif car.eq? :cons  then cadr._eval(a).cons caddr._eval(a)
            elsif car.eq? :cond  then cdr.cond a
            else  a.assoc(car).cons(cdr)._eval(a) end#is any other function, so resolve it and eval it

        #and function definitions    
        elsif caar.eq? :label
            caddar.cons(cdr)._eval [cadar, car].cons(a)
        elsif caar.eq? :lambda
            #join the environments
            caddar._eval cadar.pair(cdr.evlis(a)).append(a) 
        else
            raise "Malformed sexp: #{self}"
        end
    end

    def cond(a)
        #self is the condition pairs, a is the environment
        if caar._eval(a) then cadar._eval(a)
        else cdr.cond(a)
        end
    end

    def evlis(a)
        #to evaluate lambda expressions
        if empty? then []
        else car._eval(a).cons cdr.evlis(a)
        end
    end
end

module Kernel
    def eval!(o)
        o.send :_eval
    end
    module_function :eval!
end


class String

    def to_sexp
        read_from(self.gsub(/([()])/){|m| " #{m} "}.split)
    end

    private
        def read_from(tokens)
            raise "Unexpected EOF while reading" unless tokens.length > 0
            token = tokens.shift
            case token
                when '(' 
                    l = []
                    l << read_from(tokens) until tokens.first == ")"
                    tokens.shift
                    l
                when ')' then raise "Syntax error: unexpected ')'"
                else token.to_atom
            end
        end
end


if __FILE__ == $0
    require 'readline'
    while exp = Readline.readline("LISP > ", true)
        begin
            puts "=> #{eval!(exp.to_sexp).to_lisp}"
        rescue Exception => e
            puts "~> #{e.inspect}"
        end
    end
end
