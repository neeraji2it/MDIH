class RemoveLookingForFromProfiles < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :looking_for
  end

  def self.down
    add_column :profiles, :looking_for, :string
  end
end
