class ChangeProfileCloumns < ActiveRecord::Migration
  def self.up
#    drop_table :quick_messages
    
    add_column :profiles, :best_feature, :string, :limit => 32
    add_column :profiles, :political_view, :string, :limit => 32
    add_column :profiles, :body_hair, :string, :limit => 32
    add_column :profiles, :favorite_food, :string

    change_column :profiles, :num_of_children, :string, :limit => 32
    change_column :profiles, :want_children, :string, :limit => 32
    change_column :profiles, :body_type, :string, :limit => 32
    change_column :profiles, :marital_status, :string, :limit => 32
    change_column :profiles, :ethnicity, :string, :limit => 32
    change_column :profiles, :skin_color, :string, :limit => 32
    change_column :profiles, :eye_color, :string, :limit => 32
    change_column :profiles, :hair_color, :string, :limit => 32
    change_column :profiles, :drugs, :string,  :limit => 32
    change_column :profiles, :drink, :string,  :limit => 32
    change_column :profiles, :income_level, :string, :limit => 32
    change_column :profiles, :favorite_sports, :text

  end

  def self.down
    remove_column :profiles, :best_feature
    remove_column :profiles, :political_view
    remove_column :profiles, :body_hair
    remove_column :profiles, :favorite_food
  end
end
