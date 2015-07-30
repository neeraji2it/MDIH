class CreatePcategoriesProducts < ActiveRecord::Migration
  def self.up
    create_table :pcategories_products do |t|
      t.integer :pcategory_id
      t.integer :product_id
    end
  end

  def self.down
    drop_table :pcategories_products
  end
end
