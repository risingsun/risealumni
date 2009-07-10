ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require File.join(File.dirname(__FILE__), 'dummy')
require File.dirname(__DIR__) + '/../init'
require 'action_controller/test_process'

class DummyController < ActionController::Base
  def my_action; end
  
  attr_reader :url_for_options
  def url_for(options, *parameters_for_method_reference)
    @url_for_options = options
    "http://www.example.com"
  end
  
  def request
    @request ||= ::ActionController::TestRequest.new
  end
  
end

context "A form_for helper with a Dummy activerecord object" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::CaptureHelper
  
  setup do
    ActionView::Helpers.current_controller = @controller = DummyController.new
    @dummy = Dummy.new
  end
  
  specify "should have labelled and unlabelled versions of fields" do
    _erbout = Spec::Rails::ResponseBody.new
    
    form_for('dummy', @dummy) do |f|
      _erbout.concat f.text_field(:col1)
      _erbout.concat f.labelled_text_field("Col1", :col1)
    end

    _erbout.should_not_be_empty
    _erbout.should_have_tag :input
    _erbout.should_have_tag :label, :attributes => { :for => 'dummy_col1'}
  end
  
  specify "should wrap labelled helpers with default wrapper" do
    _erbout = Spec::Rails::ResponseBody.new
    
    form_for('dummy', @dummy) do |f|
      _erbout.concat f.labelled_text_field('Col Twoo!', :col2)
    end
    
    _erbout.should_have_tag :form #, :content => /<p>(.*)<\/p>/
  end
  
  specify "should have a fieldset method that accepts attributes and wraps other form content" do
    _erbout = Spec::Rails::ResponseBody.new
    
    form_for('dummy', @dummy) do |f|
      f.fieldset(:class => 'beebo') do
      _erbout.concat 'some content'
      end
    end
    
    _erbout.should_have_tag :fieldset, :content => 'some content'
  end
  
  specify "should autmatically mark required attributes with a wrapper class and * in label" do
    _erbout = Spec::Rails::ResponseBody.new
    
    form_for('dummy', @dummy) do |f|
      _erbout.concat f.labelled_text_field('Col1', :col1)
    end
    
    _erbout.should_have_tag :p, :attributes => { :class => 'required' }
    _erbout.should_have_tag :label, :content => /\*/
  end
  
  specify "should mark error fields with a class in the wrapper" do
    _erbout = Spec::Rails::ResponseBody.new
    
    @dummy.should_not_be_valid
    
    form_for('dummy', @dummy) do |f|
      _erbout.concat f.labelled_text_field('Col1', :col1)
    end
    
    _erbout.should_have_tag :p, :attributes => { :class => 'error required' }
    
  end
  
  specify "should accept a proc as a field wrapper" do
    _erbout = Spec::Rails::ResponseBody.new
    
    form_for('dummy', @dummy) do |f|
      f.field_wrapper = Proc.new { |content, options| content_tag :test_bung, content }
      _erbout.concat f.labelled_text_field('Col1', :col1)
    end
    
    _erbout.should_have_tag :test_bung
    _erbout.should_have_tag :label
    _erbout.should_have_tag :input
  end
  
end