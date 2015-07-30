class AddPhotoItemToInappropriatePhotos < ActiveRecord::Migration
  def self.up
    add_column :inappropriate_photos, :photo_item_type, :string
    add_column :inappropriate_photos, :photo_item_id, :integer
    remove_column :inappropriate_photos, :photo_id
  end

  def self.down
    add_column :inappropriate_photos, :photo_id, :integer
    remove_column :inappropriate_photos, :photo_item_type
    remove_column :inappropriate_photos, :photo_item_id
  end
end
