class AddRestTimeColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rest_time, :datetime
    add_column :users, :available_today, :boolean, :default => false
    add_column :users, :rest_time_hours, :integer
     remove_column  :profiles, :is_free
  end
end
