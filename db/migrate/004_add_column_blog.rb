class AddColumnBlog < ActiveRecord::Migration
  def self.up
    add_column :blogs, :public, :boolean, :default => false
    i = 0
    Blog.record_timestamps = false
    Blog.find_each do |blog|
      i += 1 if blog.update_attribute('public',blog.profile.user.is_admin?)
    end
    puts "#{i} records updated"
  end

  def self.down
    remove_column :blogs, :public
  end
end
