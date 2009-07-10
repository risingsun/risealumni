class CreateProfileEvents < ActiveRecord::Migration
  def self.up
    create_table :profile_events do |t|
      t.references :profile
      t.references :event
      t.string :role
      t.timestamps
    end
    add_column :events , :marker_id, :integer
    remove_column :events , :first_contact_person
    remove_column :events , :second_contact_person
    remove_column :events , :third_contact_person
    remove_column :events , :fourth_contact_person
    remove_column :events , :fifth_contact_person
    remove_column :events , :created_by
    remove_column :events , :type
end

  def self.down
    drop_table :profile_events
    remove_column :events,:marker_id
    add_column :events , :first_contact_person, :string
    add_column :events , :second_contact_person, :string
    add_column :events , :third_contact_person, :string
    add_column :events , :fourth_contact_person, :string
    add_column :events , :fifth_contact_person, :string
    add_column :events , :created_by, :integer
    add_column :events , :type, :string
  end
end
