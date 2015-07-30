class ChangeHeightWeightColumnTypes < ActiveRecord::Migration
  def self.up
    change_column :profiles, :height, :float
    change_column :profiles, :weight, :float
  end

  def self.down
    change_column :profiles, :height, :string, :limit => 20
    change_column :profiles, :weight, :string, :limit => 20
  end
end
