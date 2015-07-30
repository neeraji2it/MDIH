class ChangeMessagesTable < ActiveRecord::Migration
  def self.up
    add_column :messages, :user_status, :string, :limit => 20
    add_column :messages, :has_replies, :boolean, :default => false
    remove_column :messages_users, :from_id
    remove_column :messages, :replied_to
    remove_column :messages_users, :from_status
    add_column :messages, :updated_at, :datetime
    create_table :messages_replies do |t|
      t.integer :message_id 
      t.text :body
      t.integer :user_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :messages_replies
    remove_column :messages, :user_status
    remove_column :messages, :updated_at
    remove_column :messages, :has_replies
    add_column :messages_users, :from_id, :integer
    add_column :messages, :replied_to, :integer
    add_column :messages_users, :from_status, :string, :limit => 20
  end
end
