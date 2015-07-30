class ImportedContacts < ActiveRecord::Migration
  def self.up
    create_table "imported_contacts" do |t|
      t.column :user_id,                  :integer
      t.column :name,                     :string
      t.column :email,                    :string, :limit => 100
      t.column :created_at,               :datetime
    end
  end

  def self.down
    drop_table "users"
  end
end
