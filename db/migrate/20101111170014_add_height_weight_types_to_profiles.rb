class AddHeightWeightTypesToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :height_units, :string, :limit => 16
    add_column :profiles, :weight_units, :string, :limit => 10
  end

  def self.down
    remove_column :profiles, :height_units
    remove_column :profiles, :weight_units
  end
end
