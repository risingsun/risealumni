require 'rubygems'
require 'will_paginate'

module WillPaginate
  module ViewHelpers
    
    @@pagination_options.merge!({:first => '&laquo; &laquo; First',:last => 'Last &raquo; &raquo;', 
                                 :enabled_class => "enabled_", :disabled_class => "disabled_", 
                                 :first_and_previous_wrap => :span,:last_and_next_wrap => :span,
                                 :wrap_two => true})
    
    def page_entries_info(collection)
      %{%d&nbsp;-&nbsp;%d of %d} % [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ]
    end
    
    def pages_info(collection)
      %{Page %d of %d} % [
        current_page,
        last_page_no(collection)
      ]
    end
        
    def current_page
      if params[:page] == nil || params[:page] == "1"
        return "1"
      else
        params[:page]
      end
    end
    
    def last_page_no(collection)
      [((collection.total_entries - 1) / 10) + 1, 1].max.to_s
    end
    
    def page_no(collection)
      if current_page == "1"
        return "first"
      elsif current_page == last_page_no(collection)
        return "last"
      else
        return "middle"        
      end
    end

  end
  class LinkRenderer
    
    def to_html
      links = @options[:page_links] ? windowed_paginator : []
      links.unshift  wrap_first_and_previous
      links.push  wrap_last_and_next
      html = links.join(' ')
      html = links.insert(2, @options[:separator])
      @options[:container] ? @template.content_tag(:div, html, html_attributes) : html
    end
    
    protected
    
    def wrap_first_and_previous
      arr = [page_link_or_span(@collection.first_page, 'first', @options[:first]), page_link_or_span(@collection.previous_page, 'previous', @options[:prev_label]) ]
      @options[:wrap_two] ? @template.content_tag(@options[:first_and_previous_wrap], arr, :class => "pagination_left") : arr
    end
    
    def wrap_last_and_next
      arr = [page_link_or_span(@collection.next_page,     'next', @options[:next_label]), page_link_or_span(@collection.last_page,     'last', @options[:last])]
      @options[:wrap_two] ? @template.content_tag(@options[:last_and_next_wrap], arr, :class => "pagination_right") : arr
    end

    
    def page_link_or_span(page, span_class = 'current', text = nil)
      text ||= page.to_s
      if page and page != current_page
        @template.link_to text, url_for(page), :rel => rel_value(page), :class => @options[:enabled_class].to_s+span_class
      else
        @template.content_tag :span, text, :class => @options[:disabled_class].to_s+span_class
      end
    end
    
    private
    
    def rel_value(page)
      case page
      when @collection.first_page; 'start'
      when @collection.previous_page; 'prev' + (page == 1 ? ' start' : '')
      when @collection.next_page; 'next'
      when @collection.last_page; 'last'
      when 1; 'start'
      end
    end
  end
  
  class Collection < Array
    
    def first_page
      current_page > 1 ? (1) : nil
    end
    
    def last_page
      current_page < @total_pages ? (@total_pages) : nil
    end
  end
end
