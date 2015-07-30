class AddChatStatusColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :chat_status, :boolean, :default => true
  end
end
