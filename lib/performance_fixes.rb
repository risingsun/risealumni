module ActiveRecord
  class Base
    private
    def attributes_with_quotes(include_primary_key = true, include_readonly_attributes = true)
      quoted = {}
      @attributes.each_pair do |name, value|
        if column = column_for_attribute(name)
          quoted[name] = quote_value(read_attribute(name), column) unless !include_primary_key && column.primary
        end
      end
      include_readonly_attributes ? quoted : remove_readonly_attributes(quoted)
    end
  end
end

module Benchmark
  def realtime
    r0 = Time.now
    yield
    r1 = Time.now
    r1.to_f - r0.to_f
  end
  module_function :realtime
end

class BigDecimal
  alias_method :eq_without_boolean_comparison, :==
    def eq_with_boolean_comparison(other)
    return false if [FalseClass, TrueClass].include? other.class
    eq_without_boolean_comparison(other)
  end
  alias_method :==, :eq_with_boolean_comparison
end

module ActiveRecord::Validations::ClassMethods
  def validates_associated(association, options = {})
    class_eval do
      validates_each(association) do |record, associate_name, value|
        associate = record.send(associate_name)
        if associate && !associate.valid?
          associate.errors.each do |key, value|
            record.errors.add(key, value)
          end
        end
      end
    end
  end
end

