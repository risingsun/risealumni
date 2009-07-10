class CreateHouseNames < ActiveRecord::Migration
  def self.up
    create_table :house_names do |t|
      t.string :name
      t.timestamps
    end
    
  end

  def self.down
    drop_table :house_names
  end
end
