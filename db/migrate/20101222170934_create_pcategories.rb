class CreatePcategories < ActiveRecord::Migration
  def self.up
    create_table :pcategories do |t|
      t.string :name, :limit => 26
    end
  end

  def self.down
    drop_table :pcategories
  end
end
