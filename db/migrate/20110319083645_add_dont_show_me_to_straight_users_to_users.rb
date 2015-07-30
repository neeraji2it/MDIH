class AddDontShowMeToStraightUsersToUsers < ActiveRecord::Migration
  def self.up
    add_column :users,  :dont_show_me_to_straight_users,  :boolean,  :default => false
  end

  def self.down
    remove_column  :users,  :dont_show_me_to_straight_users
  end
end
