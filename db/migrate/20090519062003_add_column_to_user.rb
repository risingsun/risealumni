class AddColumnToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_uid, :integer
  end

  def self.down
    remove_column :users, :facebook_uid
  end
end
