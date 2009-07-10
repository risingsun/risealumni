class CreateNotificationControls < ActiveRecord::Migration
  def self.up
    create_table :notification_controls do |t|
      t.references :profile
      t.boolean :news, :event, :message, :blog_comment, 
                :profile_comment, :follow, :delete_friend, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :notification_controls
  end
end
