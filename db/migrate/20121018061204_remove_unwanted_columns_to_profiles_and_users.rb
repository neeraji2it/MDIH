class RemoveUnwantedColumnsToProfilesAndUsers < ActiveRecord::Migration
  def change
    remove_column :profiles,:weight
    remove_column :profiles,:hair_color
    remove_column :profiles,:eye_color
    remove_column :profiles,:skin_color
    remove_column :profiles,:num_of_children
    remove_column :profiles,:interests
    remove_column :profiles,:description
    #            remove_column :profiles,:headline
    remove_column :profiles,:nationality
    remove_column :profiles,:favorite_music
    remove_column :profiles,:favorite_tv_show
    remove_column :profiles,:favorite_books
    remove_column :profiles,:favorite_movies
    remove_column :profiles,:favorite_food
    remove_column :profiles,:favorite_avtivity
    remove_column :profiles,:favorite_type_of_cuisine
    remove_column :profiles,:what
    remove_column :profiles,:role_model
    remove_column :profiles,:fetish
    remove_column :profiles,:sexual_activity
    remove_column :profiles,:zodiac_sign
    remove_column :profiles,:favorite_sports
    remove_column :profiles,:favorite_clubs
    remove_column :profiles,:favorite_resaurants
    remove_column :profiles,:ideal_places
    remove_column :profiles,:ideal_vacation
    remove_column :profiles,:favorite_authors
    remove_column :profiles,:favorite_actors
  end
end
