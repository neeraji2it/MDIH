class CreateMessagesUsers < ActiveRecord::Migration
  def self.up
    remove_column :messages, :from
    remove_column :messages, :to
    remove_column :messages, :from_status
    remove_column :messages, :to_status
    add_column :messages, :user_id, :integer
    add_column :messages, :message_type, :string, :limit => 10
    create_table :messages_users do |t|
      t.column :message_id,             :integer
      t.column :from_id,             :integer
      t.column :to_id,               :integer
      t.column :from_status,      :string, :limit => 20
      t.column :to_status,        :string, :limit => 20
      t.timestamps
    end
  end

  def self.down
    drop_table :messages_users
    add_column :messages, :from,             :integer
    add_column :messages, :to,               :integer
    add_column :messages, :from_status,      :string, :limit => 20
    add_column :messages, :to_status,        :string, :limit => 20
    remove_column :messages, :user_id
    remove_column :messages, :message_type
  end
end

