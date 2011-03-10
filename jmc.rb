# The Lisp defined in McCarthy's 1960 paper, translated into ruby
# based on this article by Paul Graham: http://www.paulgraham.com/rootsoflisp.html
class Array
    alias :pair :zip
    alias :append :concat
    alias_method :_assoc, :assoc
    def assoc(k)
        _assoc(k).cadr
    end
end

class String
    def to_sexp
        gsub(/[()]/, "").split /\s+/
    end
    
    def atom?
        true
    end
end

class Object
    def quote
        self
    end

    def atom?
        !self.respond_to? :each
    end

    def cons(l)
        [self, l]
    end

    def eq?(o)
        self.to_sym.eql?(o) if o.is_a? Symbol
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
                rval = rval.send(if f == 'a' then :car else :cdr end) 
            end
            rval
        end
    end
    
    def _eval(a)

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
            caddar.cons(cdr).cons(list(cadar, car))._eval(a)
        elsif caar.eq? :lambda
            #join the environments
            caddar._eval(a.append(cadar.pair(cdr.evlis(a))))
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

#The REPL:
if __FILE__ == $PROGRAM_NAME
    require 'readline'
    while instr = Readline.readline('> ', true)
        begin
            puts "=> #{instr.to_sexp._eval([])}"
        rescue Exception => e
            puts "In #{instr}:\n #{e}"
        end
    end
end
