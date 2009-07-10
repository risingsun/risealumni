class RenameColumnToProfile < ActiveRecord::Migration
  def self.up
    rename_column :profiles, :year, :group
  end

  def self.down
    rename_column :profiles, :group, :year
  end
end
