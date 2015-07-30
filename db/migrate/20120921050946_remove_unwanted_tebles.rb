class RemoveUnwantedTebles < ActiveRecord::Migration
  def up
    drop_table :messages_replies
    drop_table :messages_users
  end

  def down
  end
end
