class ChangeColoumnToNotificationControls < ActiveRecord::Migration
  def self.up
    change_column :notification_controls, :news, :integer
    change_column :notification_controls, :event, :integer
    change_column :notification_controls, :message, :integer
    change_column :notification_controls, :blog_comment, :integer
    change_column :notification_controls, :profile_comment, :integer
    change_column :notification_controls, :follow, :integer
    change_column :notification_controls, :delete_friend, :integer
  end

  def self.down
    change_column :notification_controls, :news, :boolean
    change_column :notification_controls, :event, :boolean
    change_column :notification_controls, :message, :boolean
    change_column :notification_controls, :blog_comment, :boolean
    change_column :notification_controls, :profile_comment, :boolean
    change_column :notification_controls, :follow, :boolean
    change_column :notification_controls, :delete_friend, :boolean
  end
end
