class ChangeUrlTypeInSavedSearches < ActiveRecord::Migration
  def self.up
    change_column :saved_searches, :url, :text
  end

  def self.down
    change_column :saved_searches, :url, :string
  end
end
