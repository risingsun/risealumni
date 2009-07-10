class AddColumnSystemMessageToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :system_message, :boolean, :default => 0
    Profile.find(:all).each{ |p| p.create_notification_control if p.notification_control.blank? }
  end

  def self.down
    remove_column :messages, :system_message
  end
end
