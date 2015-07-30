class AddOrientationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :orientation, :string, :limit => 16
  end

  def self.down
    remove_column :users, :orientation
  end
end
