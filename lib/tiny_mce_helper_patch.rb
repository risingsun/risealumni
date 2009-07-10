module TinyMCEHelper
  def javascript_include_tiny_mce_direct
    js_path  =  RAILS_ENV == 'development' ? "tiny_mce/tiny_mce_src.js" : "tiny_mce/tiny_mce.js"
    "<script src='/javascripts/#{js_path}' type='text/javascript'></script>"
  end
  
  def javascript_include_tiny_mce__direct_if_used
    javascript_include_tiny_mce_direct if @uses_tiny_mce
  end
end
