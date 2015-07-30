class AddBillingAddessToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :address, :string
    add_column :payments, :city, :string, :limit => 30
    add_column :payments, :state, :string, :limit => 30
    add_column :payments, :zip, :string, :limit => 20
    add_column :payments, :country, :string, :limit => 30
  end

  def self.down
    remove_column :payments, :addess
    remove_column :payments, :city
    remove_column :payments, :state
    remove_column :payments, :zip
    remove_column :payments, :country
  end
end
