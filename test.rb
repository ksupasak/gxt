puts 'start'

module Utilities
  def method_one
    puts "Hello from an instance method"
  end
 
  module ClassMethods
    def method_two
      puts "Hello from a class method"
    end
  end
  
  def self.included(base)
    puts "include called"
    base.extend(ClassMethods)
  end
  
  def self.module_name
    'template'
  end
  
end

class SuperA
  
  include Utilities

  def self.module_name
    'user'
  end
  
end

class A < SuperA

  def test
    puts "test name = #{A.module_name}"
  end
  
end


a = A.new
a.method_one
a.test
A.method_two