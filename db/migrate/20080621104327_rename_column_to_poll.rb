class RenameColumnToPoll < ActiveRecord::Migration
  def self.up
     rename_column :polls, :title, :question
     remove_column :polls, :repeat_votes
     rename_column :poll_options, :question, :option
     change_column :polls, :status, :boolean,:default => true
     add_column :poll_options, :poll_responses_count, :integer, :default => 0
     change_column :polls, :status, :boolean
     remove_column :poll_options, :votes_count
  end

  def self.down
    rename_column :polls, :question, :title 
    add_column :polls, :repeat_votes
    rename_column :poll_options, :option, :question
    change_column :polls, :status, :string
    remove_column :poll_options, :poll_responses_count
    change_column :polls, :status, :boolean
    add_column :poll_options, :votes_count,:integer,:defoult => 0
  end
end
