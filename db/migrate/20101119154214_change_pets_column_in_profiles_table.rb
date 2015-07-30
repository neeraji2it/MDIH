class ChangePetsColumnInProfilesTable < ActiveRecord::Migration
  def self.up
    change_column :profiles, :pets, :string, :limit => 100
  end

  def self.down
    change_column :profiles, :pets, :string, :limit => 20
  end
end
