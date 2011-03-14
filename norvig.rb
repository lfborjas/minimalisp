#Inspired by Peter Norvig's lisp.py
#http://norvig.com/lispy.html

class Env < Hash
    attr_accessor :outer
    def initialize(parms=[], args=[], outer=nil)
        parms.zip(args).each{|k| self[k[0].to_sym] = k[1]}
        @outer = outer
    end
    def find(v)
        self.include?(v) ? self : @outer.find(v)
    end
    alias_method(:_get, :[]) unless method_defined? :_get
    def [](k)
        _get[k.to_sym]
    end
end

def add_globals(e)
    #add the math methods:
    Math.__module_init__.each{|m| e[m] = lambda{|*args| Math.send(m, *args)}}

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
end

global_env = add_globals(Env.new)

class Object
    def atom?
        return true if self.is_a? String
        !self.respond_to? :each
    end
end

class String
    def ==(o)
        return self.to_sym.eql?(o) if o.is_a? Symbol
        eql? o
    end
end

def eval!(x, env)
    if    x.atom?         then env.find(x)[x] #variable reference
    elsif !x.is_a?(Array) then x              #constant literal
    elsif x.first == :quote  then _, exp = x ; exp
    elsif x.first == :if     then _, t, c, a = x; eval!(eval!(t, env)?c : t, env)
    elsif x.first == :set!   then _, v, exp = x ; env.find(v)[v] = eval!(exp, env)
    elsif x.first == :define then _, v, exp = x ; env[v] = eval!(exp, env)
    elsif x.first == :lambda then 
end
