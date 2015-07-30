class ChangeCostColumnInProducts < ActiveRecord::Migration
  def self.up
    change_column :products, :cost, :integer
    rename_column :products, :cost, :credits
  end

  def self.down
    rename_column :products, :credits, :cost
    change_column :products, :cost, :integer
  end
end
