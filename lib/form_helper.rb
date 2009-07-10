module EnhancedFormBuilder

  class FormBuilder < ActionView::Helpers::FormBuilder
    # Within the form's block you can get good buttons with:
    #
    #   <% f.buttons do |b| %>
    #     <%= b.save %>
    #     <%= b.cancel %>
    #   <% end %>
    #
    # You can have save, cancel, edit and delete buttons.
    # Each one takes an optional label.  For example:
    #
    #     <%= b.save 'Update' %>
    #
    # See the documentation for the +button+ method for the
    # options you can use.
    #
    # You could call the button method directly, e.g. <%= f.button %>,
    # but then your button would not be wrapped with a div of class
    # 'buttons'.  The div is needed for the CSS.
    def buttons(&block)
      content = @template.capture(self, &block)
      @template.concat '<div class="buttons">', block.binding
      @template.concat content, block.binding
      @template.concat '</div>', block.binding
    end

    # Buttons and links for REST actions.  Actions that change
    # state, i.e. save and delete, have buttons.  Other actions
    # have links.
    #
    # For visual feedback with colours and icons, save is seen
    # as a positive action; delete is negative.
    #
    # type = :save|:cancel|:edit|:delete
    # TODO :new|:all ?
    #
    # Options you can use are:
    #   :label - The label for the button or text for the link.
    #            Optional; defaults to capitalised purpose.
    #   :icon  - Whether or not to show an icon to the left of the label.
    #            Optional; icon will be shown unless :icon set to false.
    #   :url   - The URL to link to (only used in links).
    #            Optional; defaults to ''.
    def button(purpose = :save, options = {})
      element, icon, nature = case purpose
      when :save   then [:button, 'tick',       'positive']
      when :cancel then [:a,      'arrow_undo', nil       ]
      when :edit   then [:a,      'pencil',     nil       ]
      when :delete then [:button, 'cross',      'negative']
      end
      legend = ( (options[:icon] == false || options[:icon] == 'false') ?
          '' :
          "<img src='/images/icons/#{icon}.png' alt=''></img> " ) +
        (options[:label] || purpose.to_s.capitalize)
      attributes_for_element = {:class => nature}.merge(element == :button  ?
          {:type => 'submit'} :
          {:href => (options[:url] || '')} )
      element ||= :a
      # TODO: separate button and link construction and use
      # link_to to gain its functionality, e.g. :back?
      @template.content_tag(element.to_s,
        legend,
        attributes_for_element)
    end

    def method_missing(*args, &block)
      if args.first.to_s =~ /^(save|cancel|edit|delete)$/
        button args.shift, *args, &block
      else
        super
      end
    end

    def labelled_collection_select(label, method, collections, value_method, text_method, options = {},html_options = {})
      label_opts = options.delete(:label) || {:class => label_class}
      wrap_class = options.delete(:wrap_class) || ''
      wrapper_opts = options.delete(:wrap) || {:class => wrap_class }
      note = options.delete(:note) || ''
      error_div_opts = options.delete(:error_div) || {}

      add_text_field_color!(options, method)

      add_class_for_collection_select!(html_options, 'collection_select')

      add_wrapper_classes!(wrapper_opts, method)
      label = add_label_content(label, method)
      
      add_text_field_color!(html_options, method)
      
      wrap_field(
        label_for(label, method, label_opts) + ' ' + 
        collection_select(method,collections, value_method, text_method, options, html_options ) + 
        add_error_div(method,error_div_opts) + 
        note, 
        wrapper_opts.delete(:with), wrapper_opts)
    end

    def labelled_state_select(label, method,default_country, options = {}, html_options = {})
      label_opts = options.delete(:label) || {:class => label_class}
      wrap_class = options.delete(:wrap_class) || ''
      wrapper_opts = options.delete(:wrap) || {:class => wrap_class }
      note = options.delete(:note) || ''
      error_div_opts = options.delete(:error_div) || {}

      add_class_for_collection_select!(html_options, 'state_select')

      add_text_field_color!(options, method)

      add_wrapper_classes!(wrapper_opts, method)
      label = add_label_content(label, method)

      wrap_field(
        label_for(label, method, label_opts) + ' ' + 
        state_select(method,default_country,options, html_options)  + 
        add_error_div(method,error_div_opts) + 
        note, 
        wrapper_opts.delete(:with), 
        wrapper_opts)
    end
    
    def self.write_label_method_for_country_select(field)
      src = <<-end_src
        def labelled_#{field}(label, method, priority_countries = {},options = {}, html_options = {})
            label_opts = options.delete(:label) || {:class => label_class}
            wrap_class = options.delete(:wrap_class) || ''
            wrapper_opts = options.delete(:wrap) || {:class => wrap_class }
            note = options.delete(:note) || ''

            error_div_opts = options.delete(:error_div) || {}

            add_class_for_collection_select!(html_options, '#{field}')
            
            add_wrapper_classes!(wrapper_opts, method)
            label = add_label_content(label, method)

            add_text_field_color!(options, method)
            
            wrap_field(
              label_for(label, method, label_opts) + ' '  + #{field}(method, priority_countries,options,html_options)  + add_error_div(method,error_div_opts) + note, 
            wrapper_opts.delete(:with), wrapper_opts)
        end
      end_src
      
      class_eval src, __FILE__, __LINE__
    end
    
    %w{country_select select}.each { |field| write_label_method_for_country_select field }

    # Date select to be labelled as well please
    write_label_method('date_select')
  end
end
