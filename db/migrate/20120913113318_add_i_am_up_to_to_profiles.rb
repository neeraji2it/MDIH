class AddIAmUpToToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :i_am_up_to, :string, :limit => 100
  end
end
