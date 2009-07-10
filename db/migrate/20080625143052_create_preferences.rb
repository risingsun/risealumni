class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.string :preference_key
      t.string :preference_value
      t.integer :preference_group_id
      t.timestamps
    end
    
  end

  def self.down
    drop_table :preferences
  end
end
