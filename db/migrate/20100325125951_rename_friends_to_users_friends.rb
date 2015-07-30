class RenameFriendsToUsersFriends < ActiveRecord::Migration
  def self.up
    rename_table :friends, :friends_users
  end

  def self.down
    rename_table :friends_users , :friends
  end
end
