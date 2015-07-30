class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string          :name,  :limit => 40
      t.integer         :user_id
      t.decimal         :cost, :precision => 20, :scale => 2
      t.string          :photo_file_name
      t.string          :photo_content_type
      t.string          :photo_file_size
      t.datetime        :photo_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
