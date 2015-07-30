class AddStatusColumnToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :status, :boolean, :default => false
  end
end
