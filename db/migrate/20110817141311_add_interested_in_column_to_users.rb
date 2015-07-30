class AddInterestedInColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :interested_in, :string, :limit => 100
  end

  def self.down
    remove_column :users, :interested_in
  end
end
