class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string, :limit => 15
      t.column :description, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end
