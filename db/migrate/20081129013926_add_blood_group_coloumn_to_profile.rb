class AddBloodGroupColoumnToProfile < ActiveRecord::Migration
  def self.up
      add_column :profiles, :blood_group, :string
  end

  def self.down
    remove_column :profiles, :blood_group
  end
end
