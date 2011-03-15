#Inspired by Peter Norvig's lisp.py
#http://norvig.com/lispy.html

class Env < Hash
    attr_accessor :outer
    def initialize(parms=[], args=[], outer=nil)
        parms.zip(args).each{|k| self[k[0].to_sym] = k[1]}
        @outer = outer
    end
    def find(v)
        v = v.to_sym
        self.include?(v) ? self : @outer.find(v)
    end
    alias_method(:_get, :[]) unless method_defined? :_get
    def [](k)
        _get k.to_sym
    end
end


class Object
    def to_atom
        Integer(self) rescue Float(self) rescue to_sym
    end

    def to_lisp
        self.is_a?(Array) ? "(#{self.collect{|v| v.to_lisp}.join(' ')})" : self.to_s
    end
end

class String
    def ==(o)
        return self.to_sym.eql?(o) if o.is_a? Symbol
        eql? o
    end

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

Kernel::Global_env = Env.new.instance_eval do |e|
    #add the math methods:
    (Math.methods - Object.methods).each{|m| e[m.to_sym] = lambda{|*args| Math.send(m, *args)}}

    #now, add the other expected methods:
    #binary:
    [:+, :-, :*, :/, :>, :<, :>= , :<=, :==].each{|m| e[m] = lambda{ |x,y| x.send(m, y)}}

    #unary:
    e[:not]    = lambda{|x| !x}
    e[:length] = lambda{|l| l.length}

    #lispy:
    e[:equal?] = lambda{|x, y| x.eql? y}
    e[:eq?]    = lambda{|x,y| x.equal? y}

    e[:cons]   = lambda{|x,y| [x]+y}
    e[:car]    = lambda{|l| l.first}
    e[:cdr]    = lambda{|l| l.slice(1..-1)}
    e[:append] = lambda{|h,t| h+t}
    e[:list]   = lambda{|*args| args}
    e[:list?]  = lambda{|x| x.is_a? Array}
    e[:null?]  = lambda{|x| x==[]}
    e[:symbol?]= lambda{|x| x.is_a?(Symbol)}
    e
end

def eval!(x, env=Global_env)
    if    x.is_a? Symbol
        env.find(x)[x] 
    elsif !x.is_a?(Array)
        x              
    else
        case x.first
         when :quote 
             _, exp = x
             exp
         when :if
             _, test, conseq, alt = x
             eval!(eval!(test, env)? conseq : alt, env)
         when :set!
             _, v, exp = x
             env.find(v)[v] = eval!(exp, env)
         when :define
             _, v, exp = x
             env[v] = eval!(exp, env)
         when :lambda 
             _, vars, exp = x
             lambda {|*args| eval!(exp, Env.new(vars, args, env))}
         when :begin
             val = nil
             x.slice(1..-1).each{|exp| val = eval!(exp, env) } 
             val
         else #it's some other function
             exps = x.collect{|exp| eval!(exp, env)}
             fun  = exps.shift
             fun.call *exps
        end
    end
end

if __FILE__ == $0
    require 'readline'
    while exp = Readline.readline("screem > ", true)
        begin
            puts "=> #{eval!(exp.to_sexp).to_lisp}"
        rescue Exception => e
            puts "~> #{e.inspect}"
        end
    end
end

