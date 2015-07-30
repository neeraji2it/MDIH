class AddDeletedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :deleted, :boolean, :default => false
    add_column :users, :deleted_at, :datetime
  end

  def self.down
    remove_column :users, :deleted
    remove_column :users, :deleted_at
  end
end
