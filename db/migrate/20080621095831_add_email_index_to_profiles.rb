class AddEmailIndexToProfiles < ActiveRecord::Migration
  def self.up
    add_index :profiles, :email, :unique => true
  end

  def self.down
    remove_index :profiles, :email
  end
end
