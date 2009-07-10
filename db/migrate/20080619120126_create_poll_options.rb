class CreatePollOptions < ActiveRecord::Migration
  def self.up
    create_table :poll_options do |t|
      t.string :question
      t.references :poll
      t.integer :votes_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :poll_options
  end
end
