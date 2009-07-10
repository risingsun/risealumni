module EnhancedFormBuilder
  
  class FormBuilder < ActionView::Helpers::FormBuilder
    
    @@default_options = {
      :error_class => ' ',
      :include_errors_in_label => false,
      :include_errors_color_in_field => false,
      :include_mandatory_in_label => false,
      :mandatory_class_for_text_field => '',
      :mandatory_class => '',
      :mandatory_label => '<span class="mandatory">*</span>',
      :error_list_wrapper => :ul,
      :error_list_class => 'error_messages',
      :field_wrapper => :div, 
      :error_div_class => "error",
      :include_errors_in_div => true,
      :label_class => '',
    }
    
    cattr_accessor :default_options
    attr_writer(*default_options.keys)
    
    # create accessors for all block local options
    # so you can set options for just a single
    # instance of the form as well as setting
    # the site wide defaults.
    #
    #   form_for(@thing) do |f|
    #     f.mandatory_class = 'arsemonkey'
    #   end
    default_options.keys.each do |field|
      
      src = <<-end_src
        
        def #{field}
          @#{field} || default_options[:#{field}]
        end
      
      end_src
      
      class_eval src, __FILE__, __LINE__
      
    end
    
    def association_select(method, options={})
      # find association, call to_options on it to make the
      # option tags then make a regular select for method_id
    end
    
    # Creates a labelled_xxx alternative to all the form helpers that take an
    # addtional label argument:
    #
    #    f.labelled_text_area 'Name', :name
    #
    # If the wrapper is specified it'll wrap the label and the field in another element,
    # you can also specify custom attributes for the label using :label in the option
    # hash.  Likewise for :wrapper.
    # 
    #  f.labelled_text_field 'Email', :email, :class => 'boo', :label => { :class => 'thing' }
    #
    # Will give you:
    #
    #   <p><label for="item_email" class="thing">Email</label> <input name="item[email]" class="boo" /></p>
    # 
    # It also automatically detects errors and validates_presence_of on fields and adds classes to the
    # field wrapper.  By default require attributes will also have a * added to the label.
    #
    def self.write_label_method(field)
      src = <<-end_src
        def labelled_#{field}(label, method, options = {})
            label_opts = options.delete(:label) || {:class => label_class}
            wrap_class = options.delete(:wrap_class) || ''
            wrapper_opts = options.delete(:wrap) || {:class => wrap_class }
            note = options.delete(:note) || ''
            
            error_div_opts = options.delete(:error_div) || {}

            add_class!(options, '#{field}')
            
            add_wrapper_classes!(wrapper_opts, method)
            label = add_label_content(label, method)

            add_text_field_color!(options, method)

            wrap_field(
              label_for(label, method, label_opts) + ' ' + #{field}(method, options) + add_error_div(method,error_div_opts) + note, 
            wrapper_opts.delete(:with), wrapper_opts)
        end
      end_src
      
      class_eval src, __FILE__, __LINE__
    end
    
    %w{text_field text_area select check_box radio_button file_field association_select
       password_field datetime_select}.each { |field| write_label_method field }

    
    
    # Outputs for errors in a more easily customisable way.
    #
    #    <% f.errors :wrap => :div, :class => 'beebo' do |field, message| %>
    #      <%= field %. <%= message %><br />
    #    <% end %>
    def errors(options={}, &block)
      unless @object.errors.empty?
        wrapper = options.delete(:wrap) || error_list_wrapper
        add_class!(options, error_list_class)
      
        out = @object.errors.collect { |field, message|
          @template.capture(field, message, &block)
        } * "\n"
      
        @template.concat wrap_field(out, wrapper, options), block.binding
      end
    end
    
    def wrap_field(content, wrapper=nil, options={})
      wrapper ||= field_wrapper
      return content unless wrapper
      
      if wrapper.is_a? Proc
         wrapper.call content, options
      else
        @template.content_tag wrapper, content, options
      end
    end
    
    def label_for(label, method, options={})
      @template.content_tag :label, label, options.merge( :for => "#{@object_name}_#{method}" )
    end
    
    # outputs a fieldset tag with the required options.
    #
    #    <% f.fieldset do %>
    #       ...
    #    <% end %>       
    def fieldset(options={}, &block)
      @template.concat @template.content_tag(:fieldset, @template.capture(&block), options), block.binding
    end
    
    def add_error_div(method, options={})
      error_msg = first_error(method) if errors?(method) && include_errors_in_div
      @template.content_tag :div, error_msg, options.merge( :class => error_div_class ) 
    end
    
    protected
    
    def add_wrapper_classes!(options, method)
      add_class!(options, error_class) if errors?(method)
      add_class!(options, mandatory_class) if mandatory?(method)
    end
    
    def add_label_content(label, method)
      labels = []
      labels.push(mandatory_label) if mandatory?(method) && include_mandatory_in_label
      labels.push(label)
      labels.push(first_error(method)) if errors?(method) && include_errors_in_label
      labels.join(' ')
    end
    
    def mandatory?(method)
      if @object.class.respond_to? :reflect_on_validations_for
        @object.class.reflect_on_validations_for(method).any? { |val| val.macro == :validates_presence_of } 
      end
    end
    
    def first_error(method)
      error = errors_for(method)
      if error.is_a? Array
        error.first
      else
        error
      end
    end
    
    def errors_for(method)
      @object && @object.errors[method]
    end
    
    def errors?(method)
      @object && @object.errors[method]
    end
    
    def add_class!(options, new_class)
      options[:class] = [options[:class], new_class].compact * ' '
    end
    
    def add_text_field_color!(options, method)
      options[:class] = [options[:class], mandatory_class_for_text_field].compact * ' ' if mandatory?(method) && include_errors_color_in_field
    end
    
    def add_class_for_collection_select!(html_options, new_class)
      html_options[:class] = [html_options[:class], new_class].compact * ' '
    end

  end
  
end