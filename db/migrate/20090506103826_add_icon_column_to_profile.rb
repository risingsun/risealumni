class AddIconColumnToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :icon_file_name, :string
    add_column :profiles, :icon_content_type, :string
    Profile.connection.execute("update profiles set icon_file_name = icon")
    remove_column :profiles, :icon
  end

  def self.down
    add_column :profiles, :icon, :string
    Profile.connection.execute("update profiles set icon = icon_file_name")
    remove_column :profiles, :icon_file_name
    remove_column :profiles, :icon_content_type
  end

end
