require 'jmc'

module Test::Unit
    class TestCase
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

class TestLisp < Test::Unit::TestCase
    must "do shit " do
    end
end

