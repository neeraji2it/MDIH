class CreateUserLocations < ActiveRecord::Migration
  def self.up
    create_table :user_locations do |t|
      t.column    "user_id", :integer
      t.column    "ip_address", :string, :limit => 20
      t.column    "lat", :decimal
      t.column    "lng", :decimal
      t.column    "state", :string , :limit => 20
      t.column    "city", :string , :limit => 20
      t.timestamps
    end
    add_index  :user_locations, [:lat, :lng]
  end

  def self.down
    remove_index  :user_locations, [:lat, :lng]
    drop_table :user_locations
  end
end
