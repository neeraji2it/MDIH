class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.integer :user_id
      t.string :name, :limit => 40
      t.text :description
      t.integer :cover_photo_id
      t.timestamps
    end
  end

  def self.down
    drop_table :albums
  end
end
