class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :user_id 
      t.integer :invited_id
      t.boolean :emailed_invitation, :default => false
      t.text :message
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :invitations
  end
end
