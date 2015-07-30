class AddTokSessionIdTokTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tok_session_id, :string
    add_column :users, :tok_token, :text
    add_column :users, :video_chat_receiver_id, :integer
    add_column :users, :video_chat_sender_id, :integer
  end
end
