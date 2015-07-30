class AddFacebookColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_id, :integer, :limit => 8
    add_column :users, :fb_small_image, :string
    add_column :users, :fb_big_image, :string
  end

  def self.down
    remove_column :users, :facebook_id
    remove_column :users, :fb_small_image
    remove_column :users, :fb_big_image
  end
end
