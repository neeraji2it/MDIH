class CreateDraftMessagesUsers < ActiveRecord::Migration
  def self.up
    create_table :draft_messages_users do |t|
      t.integer :to_id
      t.integer :message_id
    end
  end

  def self.down
    drop_table :draft_messages_users
  end
end
