class CreateInappropriatePhotos < ActiveRecord::Migration
  def self.up
    create_table :inappropriate_photos do |t|
      t.integer  :photo_id
      t.integer  :user_id
      t.text     :comment
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :inappropriate_photos
  end
end
