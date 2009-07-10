class EventObserver < ActiveRecord::Observer
  include ActionView::Helpers::TextHelper
  include ActionController::UrlWriter
  observe :event

  def after_create(event)
    TweetsWorker.async_send_event_tweets(event.id) if TWITTER_ENABLED
  end
end
