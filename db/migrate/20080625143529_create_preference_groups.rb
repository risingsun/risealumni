class CreatePreferenceGroups < ActiveRecord::Migration
  def self.up
    create_table :preference_groups do |t|
      t.string :group
      t.timestamps
    end
    
    
    

  end

  def self.down
    drop_table :preference_groups
  end
end
