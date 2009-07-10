class AddColumnTypeToPreference < ActiveRecord::Migration
  def self.up
    add_column :preferences, :field_type, :string
    
  end
  

  def self.down
    remove_column :preferences, :field_type, :string
  end
end
