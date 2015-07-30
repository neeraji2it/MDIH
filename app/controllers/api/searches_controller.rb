class Api::SearchesController < ApplicationController

#  skip_before_filter :is_logged?, :only => [:simple_results]
  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth

  # Will search for users by given username or option selected
  def simple_results
    get_simple_search_results(false, params)
    @users.collect{|user| user.basic_profile_info }
    respond_to do |format|
      format.xml { render :xml => @users }
      format.json { render :json => @users }
    end
  end

  def advance_results
    query_params = ["sexual_activity", "zodiac_sign", "favorite_sports", "ideal_vacation", "interests", "body_type",
      "favorite_tv_show", "fetish", "education_level", "favorite_music", "role_model", "favorite_actors",
      "favorite_type_of_cuisine", "drink", "favorite_resaurants", "ideal_places", "smoke", "languages_spoken",
      "income_level", "favorite_books", "favorite_authors", "favorite_activity", "religion", "favorite_clubs", "marital_status",
      "drugs", "profession", "favorite_movies", "best_feature", "political_view", "favorite_food",
      "ethnicity",  "eye_color", "skin_color",  "hair_color", "body_hair"
    ]
    for query_param in query_params
      if params[query_param.to_sym].to_s.include?(',')
        params.merge!(query_param.to_sym => params[query_param.to_sym].split(','))
      end
    end
    get_advance_search_results(false, params)
    @users.collect{|user| user.basic_profile_info }
    respond_to do |format|
      format.xml { render :xml => @users }
      format.json { render :json => @users }
    end
  end

  def near_by_location
    gender_condition = GENDERS.include?(params[:gender]) ?  "AND gender = '#{params[:gender]}'" : ''
    user_ids = UserLocation.get_nearby_locations(params[:lat], params[:lng]).map{|location| location.user_id}.uniq
    @users = !user_ids.empty? ? User.find(:all, :conditions => ["id IN (#{user_ids.join(',')}) #{gender_condition}"]) : []
    respond_to do |format|
      format.xml { render :xml => @users }
      format.json { render :json => @users }
    end
  end

end
