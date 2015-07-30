class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column          :user_id,   :integer
      
      t.column          :address_one,    :text
      t.column          :address_two,    :text
      t.column          :city,    :string
      t.column          :state,    :string
      t.column          :country,    :string
      t.column          :zip,    :string, :limit => 20
      t.column          :height,    :string, :limit => 20
      t.column          :weight,    :string, :limit => 20
      t.column          :body_type,    :string, :limit => 20
      t.column          :marital_status,    :string, :limit => 20
      t.column          :ethnicity,    :string, :limit => 20
      t.column          :hair_color,    :string, :limit => 20
      t.column          :eye_color,    :string, :limit => 20
      t.column          :skin_color,    :string, :limit => 20
      t.column          :num_of_children,    :integer
      t.column          :want_children,    :string, :limit => 20
      t.column          :pets,    :string, :limit => 20
      t.column          :drink,    :string, :limit => 20
      t.column          :drugs,    :string, :limit => 20
      t.column          :income_level,    :string, :limit => 20
      t.column          :languages_spoken,    :text
      t.column          :religion,    :string
      t.column          :profession,    :string
      t.column          :education_level,    :string

      t.column          :avatar_file_name,    :string
      t.column          :avatar_content_type,    :string
      t.column          :avatar_file_size,    :integer
      t.column          :avatar_updated_at,    :datetime

      t.column          :interests,    :text
      t.column          :description,    :text
      t.column          :looking_for,    :string, :limit => 20
      t.column          :headline,    :string
      t.column          :nationality,    :string
      t.column          :favorite_music,    :string
      t.column          :favorite_tv_show,    :string
      t.column          :favorite_books,    :string
      t.column          :favorite_movies,    :string
      t.column          :favorite_food,    :string
      t.column          :favorite_avtivity,    :string
      t.column          :favorite_type_of_cuisine,    :string
      t.column          :what,    :string
      t.column          :role_model,    :text

      t.column          :fetish,  :string
      t.column          :sexual_activity,  :string
      t.column          :smoke,    :string, :limit => 30
      t.column          :zodiac_sign,    :string, :limit => 20
      t.column          :favorite_sports,  :string
      t.column          :favorite_clubs,  :string
      t.column          :favorite_resaurants,  :string
      t.column          :ideal_places,  :string
      t.column          :ideal_vacation,  :string
      t.column          :favorite_authors,  :string
      t.column          :favorite_actors,  :string

#      t.column          :looking_by,   :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
