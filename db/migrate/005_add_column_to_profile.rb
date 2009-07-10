class AddColumnToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :house_name, :string
    add_column :profiles, :delicious_name, :string   
  end

  def self.down
    remove_column :profiles, :house_name
    remove_column :profiles, :delicious_name
  end
end
