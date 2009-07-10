class AddInformationToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :middle_name, :string
    add_column :profiles, :linkedin_name, :string
    add_column :profiles, :msn_username, :string
    add_column :profiles, :twitter_username, :string
    rename_column :student_checks, :user_id, :profile_id
  end

  def self.down
    remove_column :profiles, :twitter_username
    remove_column :profiles, :msn_username
    remove_column :profiles, :linkedin_name
    remove_column :profiles, :middle_name
    rename_column :student_checks, :profile_id, :user_id
  end
end
