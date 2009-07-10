class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :profile_id
      t.string  :email
      t.timestamps
    end
  end
  
  def self.down
    drop_table :invitations
  end
end
