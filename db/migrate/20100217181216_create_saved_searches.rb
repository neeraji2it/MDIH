class CreateSavedSearches < ActiveRecord::Migration
  def self.up
    create_table :saved_searches do |t|
      t.column :user_id,        :integer
      t.column :name,           :string
      t.column :url,            :string
      t.column :created_at,     :datetime
    end
  end

  def self.down
    drop_table :saved_searches
  end
end
