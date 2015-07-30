class AddLoggedInFromToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :logged_in_from, :string, :limit => 10
  end

  def self.down
    remove_column :users, :logged_in_from
  end
end
