class AddLookingForToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :looking_for, :string, :limit => 100
  end

  def self.down
    remove_column :users, :looking_for
  end
end
