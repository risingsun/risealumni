require 'yaml'
require 'set'

module ActiveRecord
  class Base
    DUPLICATE_ERROR_MESSAGES = ["Duplicate entry"]
    alias_method :save, :save_new
    def save_new
      begin
        save    
      rescue ActiveRecord::StatementInvalid => error
        if DUPLICATE_ERROR_MESSAGES.any? { |msg| error.message =~ /#{Regexp.escape(msg)}/ }
          logger.info "Duplicate Entry exception from DB"
          errors.add_to_base('Duplicate item not allow')
          return false
        else
          raise
        end
      end
    end
  end

end