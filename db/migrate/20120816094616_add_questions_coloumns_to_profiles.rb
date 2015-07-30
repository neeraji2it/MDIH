class AddQuestionsColoumnsToProfiles < ActiveRecord::Migration
  def change
    add_column  :profiles, :important_things , :text
    add_column  :profiles, :funny_story_when_we_meet , :text
    add_column  :profiles, :my_pet_peeves_are, :text
    add_column  :profiles, :i_am_really_good_at, :text
    add_column  :profiles, :favorite_books_music_movies, :text
    add_column  :profiles, :embarrassing_thing, :text
    add_column  :profiles, :anything_i_want, :text
    add_column  :profiles, :things_i_would_never_do, :text
    add_column  :profiles, :my_friends_tell_me_that_i_am, :text
    add_column  :profiles, :private_about_me, :text
    add_column  :profiles, :my_bucket_list, :text
    add_column  :profiles, :on_a_normal_weekend_i, :text
    add_column  :profiles, :most_interesting_place, :text
    add_column  :profiles, :weirdest_thing_that_i_know, :text
    add_column  :profiles, :i_fear_the_most, :text
    add_column  :profiles, :my_best_feature_is, :text
    remove_column  :profiles, :when_i_am_not_working_i
    remove_column  :profiles, :cannot_live_without
  end
end
