class CreatePolls < ActiveRecord::Migration
  def self.up
    create_table :polls do |t|
      t.string :title
      t.string :status
      t.references :profile
      t.boolean :repeat_votes
      t.boolean :public
      t.integer :votes_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :polls
  end
end
