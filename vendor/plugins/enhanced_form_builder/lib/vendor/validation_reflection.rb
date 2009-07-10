#--
# Copyright (c) 2006, Michael Schuerig, michael@schuerig.de
#
# == License
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# See http://www.gnu.org/copyleft/lesser.html
#++


require 'active_record/reflection'

# Based on code by Sebastian Kanthak
# See http://dev.rubyonrails.org/ticket/861
module ValidationReflection # :nodoc:
  VALIDATIONS = %w(
     validates_acceptance_of
     validates_associated
     validates_confirmation_of
     validates_exclusion_of
     validates_format_of
     validates_inclusion_of
     validates_length_of
     validates_numericality_of
     validates_presence_of
     validates_uniqueness_of
  ).freeze

  def self.included(base)
    base.extend(ClassMethods)

    for validation_type in VALIDATIONS
      base.module_eval <<-"end_eval"
        class << self
          alias_method :#{validation_type}_without_reflection, :#{validation_type}

          def #{validation_type}_with_reflection(*attr_names)
            #{validation_type}_without_reflection(*attr_names)
            configuration = attr_names.last.is_a?(Hash) ? attr_names.pop : nil
            for attr_name in attr_names
              write_inheritable_array "validations", [ ActiveRecord::Reflection::MacroReflection.new(:#{validation_type}, attr_name, configuration, self) ]
            end
          end

          alias_method :#{validation_type}, :#{validation_type}_with_reflection
        end
      end_eval
    end
  end

  module ClassMethods

    # Returns an array of MacroReflection objects for all validations in the class
    def reflect_on_all_validations
      read_inheritable_attribute("validations") || []
    end

    # Returns an array of MacroReflection objects for all validations defined for the field +attr_name+ (expects a symbol)
    def reflect_on_validations_for(attr_name)
      reflect_on_all_validations.find_all do |reflection|
        reflection.name.to_s == attr_name.to_s
      end
    end

  end

end
  
ActiveRecord::Base.class_eval do
  include ValidationReflection
end
