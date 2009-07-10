require 'rubygems'
require 'ostruct'
require 'greeting'
require 'form_helper'
require 'less_captcha_patch'
require 'digest/sha1'
require 'will_paginate_view_helpers'
require 'tiny_mce_helper_patch'
require 'flickr_patch'
require 'flickr_helper_patch'
require 'smtp_tls'



ActionView::Base.send(:include, FlickrHelperPatch  )
ActionController::Base.send(:include, FlickrHelperPatch  )


#Less::JsRoutes.generate!

ActionMailer::ARMailer.delivery_method = :activerecord # Only this notifier will use as active record

WillPaginate::ViewHelpers.pagination_options.merge!({:page_links => false})

ActionController::Base.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache" # TODO Rails 2.1 Add this line