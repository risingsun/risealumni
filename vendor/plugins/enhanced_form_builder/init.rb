require 'vendor/validation_reflection'
require 'enhanced_form_builder/form_builder'

# Make it the default form builder
ActionView::Base.default_form_builder = EnhancedFormBuilder::FormBuilder

# Remote rails default error div thing
ActionView::Base.field_error_proc = Proc.new { |field, instance| field }