class AddCommentsCountToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :comments_count, :integer, :default => 0
    execute "update blogs set comments_count = (select count(*) from comments where commentable_type = 'Blog' and commentable_id = blogs.id)"
    add_column :profiles, :comments_count, :integer, :default => 0
    execute "update profiles set comments_count = (select count(*) from comments where commentable_type = 'Profile' and commentable_id = profiles.id)"
    add_column :events, :comments_count, :integer, :default => 0
    execute "update events set comments_count = (select count(*) from comments where commentable_type = 'Event' and commentable_id = events.id)"
  end

  def self.down
    remove_column :blogs, :comments_count
    remove_column :profiles, :comments_count
    remove_column :events, :comments_count
  end
end
