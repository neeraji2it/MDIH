class AddZipCodeColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :zip, :string, :limit => 10
    remove_column :profiles, :zip
  end

  def self.down
    remove_column :users, :zip_code
    add_column :users, :zip, :string, :limit => 20
  end
end
