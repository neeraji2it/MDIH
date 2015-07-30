class AddCreditsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :credits, :integer, :default =>  0
    change_column :payments, :amount, :float
  end

  def self.down
    remove_column :users, :credits
  end
end
