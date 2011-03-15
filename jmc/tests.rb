require 'jmc'
require 'test/unit'

module Test::Unit
    class TestCase
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

class LispTest < Test::Unit::TestCase

    alias_method :t?, :assert

    must "assoc numbers to themselves"do
        t? [].assoc(1) == 1 
    end
    
    must "assoc the true and false atoms to themselves" do
        [:t, :f].each do |a|
            t? [].assoc(a) == a
        end
    end

    must "correctly identify atoms" do
        t? "a".atom? and 1.atom? and :x.atom?
        assert_false [].atom? or {}.atom?
    end
    
    must "create cons cells" do
        t? 1.cons([2,3,4]) == [1,2,3,4]
    end

    must "say that strings and symbols with the same chars are eq" do 
        t? "hi".eq? :hi
    end
    
    must "get the head of a list" do 
        t? [1,2,3,4].car == 1
    end

    must "get the tail of a list" do
        t? [1,2,3,4].cdr = [2,3,4]
    end

    must "respond correctly to arbitrary cXr methods" do
        t? [[[1,2], 3], 4].caaar == 1    
        t? [1, [2, [3, 4]]].cadadr = [3,4]
    end

    must "quote exps" do
        t? [:quote, :x]._eval == :x
    end

    must "quote stuff" do
        t? [:quote, :x]._eval == :x
    end

    must "find atoms" do
        t? [:atom?, 1]._eval == true
    end

    must "determine equality" do
        t? [:eq?, 2, 2]._eval == true
        t? [:eq?, 3, 4]._eval == false
    end

    must "find heads" do 
        t? [:car, [:quote, [1,2,3]]]._eval == 1
    end

    must "find tails" do
        t? [:cdr, [:quote, [1,2,3]]]._eval == [2,3] 
    end

    must "cons stuff together" do
        t? [:cons, 1, [:quote, [2,3,4]]]._eval == [1,2,3,4]
    end

    must "eval conditions" do
        t? [:cond, [[:eq?, 2, 2], :t], [:t, :f]]._eval == :t
        t? [:cond, [[:eq?, 2, 3], :t], [:t, :f]]._eval == :f
    end
    
    must "be able to use pre-loaded environments" do
        t? [:null?, [:quote, []]]._eval [[:null?, [:lambda, [:l], [:eq?, :l, [:quote, []]]]]]
        f? [:null?, [:quote, [1,2]]]._eval [[:null?, [:lambda, [:l], [:eq?, :l, [:quote, []]]]]]
    end

    must "apply anonymous functions" do
        t? [[:lambda, [:x], [:atom?, :x]], 1]._eval == true
        t? [[:lambda, [:x], [:atom?, :x]], [:quote, [1,2]]]._eval == false
    end

    must "apply named functions" do
        t? [[:label, :l, [:lambda, [:x], [:eq?, :x, 2]]], 2]._eval == true
    end

    must "eval named functions with an environ" do
        t? [[:label, :cadar,
                [:lambda, [:s],
                    [:car, [:cdar, :s]]]],
            [:quote, [[[1,2],3], 4]]]._eval(
            [[:cdar, [:lambda, [:l], [:cdr, [:car, :l]]] ]]
        )
    end

    must "eval recursive functions" do 
        t? [[:label, :append,
                [:lambda, [:x, :y],
                    [:cond,
                        [[:null?, :x], :y],
                        [:t, [:cons, [:car, :x], [:append, [:cdr, :x], :y]]]]]],
            [:quote, [1,2,3]], [:quote, [5,6,7]]
        ]._eval(
             [[:null?, [:lambda, [:l], [:eq?, :l, [:quote, []]]]]]
        ) == [1,2,3,5,6,7]
    end
    
    must "eval higher order functions" do

        t? [[:label, :maplist,
                [:lambda, [:x, :p],
                    [:cond,
                        [[:null?, :x], [:quote, []]],
                        [:t, [:cons, [:p, :x], [:maplist, [:cdr, :x], :p]]]]]],
            [:quote, [1,2,3,2]], [:quote, [:lambda, [:e], [:eq?, :e, 2]]]
        ]._eval(
             [[:null?, [:lambda, [:l], [:eq?, :l, [:quote, []]]]]]
        )
    end

end



