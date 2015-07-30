class RemoveSessionIdAndSessionTokenFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :tok_session_id
    remove_column :users, :tok_token
    remove_column :users, :video_chat_receiver_id
    remove_column :users, :video_chat_sender_id
    remove_column :profiles,:weight_units
  end
end
