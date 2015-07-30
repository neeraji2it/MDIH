class RemoveFavoriteFoodFromProfiles < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :favorite_food
  end

  def self.down
    add_column :profiles, :favorite_food, :string
  end
end
