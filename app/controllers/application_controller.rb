# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'will_paginate/array' 
class ApplicationController < ActionController::Base
  include Facebooker2::Rails::Controller
  include AuthenticatedSystem
  before_filter :set_locale, :http_auth
  layout :get_layout
  #  before_filter :set_time_zone


  #  def set_time_zone
  #    Time.zone = "UTC"
  #  end

  def http_auth
    if BASE_URL.include?("http://staging2.myroya.com")
      authenticate_or_request_with_http_basic do |username, password|
        return true if username == 'mdihdev' and password == 'bangalore'
      end
    end
  end

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end


  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem

  # Will send error email allert when error occured in the application
  #include ExceptionNotifiable
  #  consider_local "64.72.18.143", "14.17.21.25"
  #  local_addresses.clear
  #include ActionView::Helpers::NumberHelper


  DATE_FORMAT = /^([0-9]{2}\/[0-9]{2}\/[0-9]{4})$/

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  #
  #    rescue_from ActionController::RoutingError, ActionController::UnknownController, ActionController::UnknownAction, :with => :render_404
  #    rescue_from RuntimeError, ActiveRecord::RecordNotFound, Riddle::ConnectionError, NameError, :with => :render_500
  helper_method :pounds_to_kgs, :kgs_to_pounds, :cm_to_inches, :inches_to_cm, :display_cm_to_inches, :user_time_zone

  before_filter :is_logged?, :is_valid_account?, :set_alert_variables#, :add_wwww_to_url
  #before_filter :set_facebook_session
  before_filter :set_last_accessed_at, :if => :logged_in?

  #  ActionView::Helpers::PrototypeHelper.instance_eval { remove_const(:JQUERY_VAR) }
  #  ActionView::Helpers::PrototypeHelper.const_set(:JQUERY_VAR, 'jQuery')
  def get_layout
    if current_user
      return 'user'
    else
      return  'application'
    end
  end
  def after_login(user)
    Juggernaut.publish("login:#{user.id}", user.json_data.to_json)
  end

  def after_logout(user)
    Juggernaut.publish("login:#{user.id}", user.json_data.to_json)
  end

  def add_wwww_to_url
    unless current_user
      if !request.xhr? and !params[:controller].include?("api/")
        if (request.host.to_s.include?('mydateishere') and !request.host.to_s.include?('www'))
          www_url = BASE_URL+(request.url.to_s.split(".com")[1].to_s)
          redirect_to www_url
        elsif (request.host.to_s.include?('mdih'))
          www_url = BASE_URL+(request.url.to_s.split(".co")[1].to_s)
          redirect_to www_url
        end
      end
    end
  end

  def set_last_accessed_at
    current_user.last_accessed_at = Time.now
    current_user.save(:validate => false)
  end

  # to check whether user is logged-in or not. If not will redirect to login page
  def is_logged?
    #    session[:user_id] = nil
    if params[:controller].include?('api/')
      authenticate_or_request_with_http_basic do |username, password|
        self.current_user = User.authenticate(username, password, false)
      end
    else
      unless logged_in?
        flash[:error] = I18n.t('application.is_logged.error')
        #      redirect_to "/"
        if request.xhr?
          render :update do |page|
            page.redirect_to signup_path
            page << "alert(#{I18n.t('application.is_logged.alert')})"
          end
        else
          redirect_to signup_path
          return
        end
      end
      # @per_page = session[:per_page] = params[:per_page] || (session[:per_page] || 10)
    end
    if params[:user_id] #and User.exists?(:login => params[:user_id])
      begin
        @user = User.find(params[:user_id])
      rescue
        logger.info ">>>>>>>>>>>>>>>>"
        logger.info "User not found with #{params[:user_id]}"
      end
    end

  end

  def is_admin?
    unless current_user.is_admin?
      flash[:error] = I18n.t('user.general_error')
      redirect_to "/"
    end
  end

  def is_valid_account?
    if current_user and (current_user.email.to_s.blank? or current_user.gender.to_s.blank? or current_user.orientation.to_s.blank?)
      flash[:error] = I18n.t('application.is_valid_account.error')
      redirect_to edit_user_path(current_user)
    end
  end

  # send notification from application to facebook user
  def send_facebook_notification(facebook_uids,message)
    @facebook_session = Facebooker::CanvasSession.create(ENV['FACEBOOK_CONNECT_API'], ENV['FACEBOOK_SECRET_KEY'])
    body = <<-MESSAGE
              <fb:fbml>
              #{ message }
              </fb:fbml>
    MESSAGE
    @facebook_session.send_notification(facebook_uids,body)
  end

  def kgs_to_pounds(value)
    return (value.to_f * 2.21).to_f.round(2)
  end

  def pounds_to_kgs(value)
    return (value.to_f / 2.21).to_f.round(2)
  end

  def cm_to_inches(centemetrs)
    feets = (centemetrs.to_f / 30.48).floor
    inches_total  = (centemetrs.to_f / 2.54)
    inches = inches_total - (feets * 12)
    return inches == 10 ? number_with_precision("#{feets}.#{inches}".to_f, :precision => 2) : "#{feets}.#{inches}".to_f
  end

  def inches_to_cm(inches)
    feets, inc = inches.to_s.split('.').first, inches.to_s.split('.').last
    return ((feets.to_i * 30.48) + (inc.to_i * 2.54)).to_f
  end

  def display_cm_to_inches(centemetrs)
    feets = (centemetrs.to_f / 30.48).floor
    inches_total  = (centemetrs.to_f / 2.54)
    inches = inches_total - (feets * 12)
    return "#{feets}'#{inches.to_i}"
  end

  def set_alert_variables
    if current_user and !current_user.last_login_at.nil? and session[:viewed_receved_gifts].nil?
      @latest_receive_gift = SentGift.count(:conditions => ["sent_to = #{current_user.id} AND sent_on > '#{current_user.last_login_at.strftime('%Y-%m-%d %H:%M:%S')}' AND receiver_status != 'deleted'"])   if session[:viewed_receved_gifts].nil?
    end
  end

  # Will returned the searched results. This methdo required two parametes first is boolean, if it true the results will be paginated else will return all matched users. Second is search parameters
  def get_simple_search_results(pagination, params={})
    if params[:user_name]
      @user_ids = User.search_for_ids "*#{params[:user_name]}*", :with => {:role_id => 2}
      @user_ids = current_user ? (@user_ids - ((current_user.my_blocked_users.map{|bu| bu.blocked_user_id}) << current_user.id)) : @user_ids
      @users = if !@user_ids.empty?
        if pagination
          User.find(:all, :conditions => ["users.id IN (#{@user_ids.join(',')})"], :include => [:profile], :order => "profiles.avatar_updated_at DESC, last_accessed_at DESC").paginate(:page => params[:page], :per_page => 10)
        else
          User.find(:all, :conditions => ["users.id IN (#{@user_ids.join(',')})"], :include => [:profile], :order => "profiles.avatar_updated_at DESC, last_accessed_at DESC")
        end
      else
        [].paginate
      end
    else
      conditions = basic_search_conditions
      if current_user
        conditions << "users.id NOT IN (#{current_user.my_blocked_users.map{|bu| bu.blocked_user_id}.join(', ')},#{current_user.id})" if !current_user.my_blocked_users.empty?
        if params[:has_contacted] and !current_user.contacted_user_ids.compact.empty?
          conditions << "(users.id NOT IN (#{current_user.contacted_user_ids.compact.join(',')}))"
        end
      end
      if params[:has_picture] == 'on'
        #        conditions << "profiles.avatar_file_name IS NOT NULL"
        #        @users = if pagination
        #          User.find(:all, :joins => "left join profiles on profiles.user_id = users.id", :conditions => [conditions.join(" AND ")], :order => "last_accessed_at DESC", :select => "users.*").paginate(:per_page => 10, :page => params[:page])
        #        else
        #          User.find(:all, :joins => "left join profiles on profiles.user_id = users.id", :conditions => [conditions.join(" AND ")], :order => "last_accessed_at DESC", :select => "users.*", :include => [:profile])
        #        end
      else
        @users =  if pagination
          User.find(:all, :conditions => [conditions.join(" AND ")], :include => [:profile], :order => "profiles.avatar_updated_at DESC, last_accessed_at DESC").paginate(:per_page => 10, :page => params[:page])
        else
          User.find(:all, :conditions => [conditions.join(" AND ")], :include => [:profile], :order => "profiles.avatar_updated_at DESC, last_accessed_at DESC")
        end
      end
    end
  end

  # Will returned the searched results. This methdo required two parametes first is boolean, if it true the results will be paginated else will return all matched users. Second is search parameters
  def get_advance_search_results(pagination,params={})
    query = {}
    #    query_params = ["sexual_activity", "zodiac_sign", "favorite_sports", "ideal_vacation", "interests", "body_type",
    #      "favorite_tv_show", "fetish", "education_level", "favorite_music", "role_model", "favorite_actors",
    #      "favorite_type_of_cuisine", "drink", "favorite_resaurants", "ideal_places", "smoke", "languages_spoken",
    #      "income_level", "favorite_books", "favorite_authors", "favorite_activity", "religion", "favorite_clubs", "marital_status",
    #      "drugs", "profession", "favorite_movies", "best_feature", "political_view", "favorite_food"
    #      #, "ethnicity",  "eye_color", "skin_color",  "hair_color", "body_hair"
    #    ]
    query_params = [ "body_type", "education_level", "drink", "smoke", "languages_spoken",
      "income_level", "religion", "marital_status", "drugs", "profession"
      #, "ethnicity",  "eye_color", "skin_color",  "hair_color", "body_hair"
    ]
    for query_param in query_params
      if !params[query_param.to_sym].to_s.blank?
        query.merge!(query_param.to_sym => (params[query_param.to_sym].class.to_s == "String" ? params[query_param.to_sym] : params[query_param.to_sym].join(", ")))
      end
    end
    profile_conditions = []
    #    if params[:has_picture] == "1"
    #      profile_conditions << "avatar_file_name IS NOT NULL"
    #    end
    #    if !params[:has_kids].to_a.empty?
    #      profile_conditions << "num_of_children IN (#{params[:has_kids].join(',')})"
    #    end
    if !params[:want_kids].to_a.empty?
      profile_conditions << "want_children IN (#{params[:want_kids].map{|wk| "\"#{wk}\""}.join(',')})"
    end

    if params[:ethnicity]
      profile_conditions << "ethnicity IN (#{params[:ethnicity].map{|e|"'#{e}'"}.join(',')})"
    end
    #    if params[:eye_color]
    #      profile_conditions << "eye_color IN (#{params[:eye_color].map{|ec|"'#{ec}'"}.join(',')})"
    #    end
    #    if params[:skin_color]
    #      profile_conditions << "skin_color IN (#{params[:skin_color].map{|sc|"'#{sc}'"}.join(',')})"
    #    end
    #    if params[:hair_color]
    #      profile_conditions << "hair_color IN (#{params[:hair_color].map{|hc|"'#{hc}'"}.join(',')})"
    #    end
    #    if params[:body_hair]
    #      profile_conditions << "body_hair IN (#{params[:body_hair].map{|bh|"'#{bh}'"}.join(',')})"
    #    end

    if params[:height_any].nil?
      if params[:height_in] == 'Inches'
        if params[:height_feets_from]
          inches_from = inches_to_cm(params[:height_feets_from]+"."+params[:height_inches_from])
          profile_conditions << "height >= #{inches_from}"  #"height >= #{(params[:height_feets_from]+"."+params[:height_inches_from]).to_f - 0.1}"
        end
        if params[:height_feets_from] and params[:height_feets_to]
          inches_to = inches_to_cm(params[:height_feets_to]+"."+params[:height_inches_to])
          profile_conditions << "height <= #{inches_to}"  #"height <= #{(params[:height_feets_to]+"."+params[:height_inches_to]).to_f + 0.1}"
        end
      else
        if params[:height_cm_from]
          profile_conditions << "height >= #{params[:height_cm_from]}"  #"height >= #{(params[:height_feets_from]+"."+params[:height_inches_from]).to_f - 0.1}"
        end
        if params[:height_cm_from] and params[:height_cm_to]
          profile_conditions << "height <= #{params[:height_cm_to]}"  #"height <= #{(params[:height_feets_to]+"."+params[:height_inches_to]).to_f + 0.1}"
        end
      end
    end
    #    if params[:weight_any].nil?
    #      if params[:weight_from]
    #        profile_conditions << "weight >= #{(params[:weight_in] == 'Kgs' ? kgs_to_pounds(params[:weight_from].to_f) : params[:weight_from].to_f)}"
    #      end
    #      if params[:weight_from] and params[:weight_to]
    #        profile_conditions << "weight <= #{(params[:weight_in] == 'Kgs' ? kgs_to_pounds(params[:weight_to].to_f) : params[:weight_to].to_f)}"
    #      end
    #    end
    sort = if params[:sort].to_s.blank? or params[:sort] == "Age"
      "users.date_of_birth DESC"
    elsif params[:sort] == "Location"
      "profiles.city, profiles.state, profiles.country"
    elsif params[:sort] == "Last login"
      "users.last_login_at DESC"
    else
      "last_accessed_at DESC"
    end
    sort = "profiles.avatar_updated_at DESC, "+sort
    if !query.empty? or !profile_conditions.empty?

      @profile_ids = Profile.search_for_ids  :conditions => query, :match_mode => :any
      @users = [].paginate
      if !@profile_ids.empty?
        profile_conditions << (!@profile_ids.empty? ? ["id IN (#{@profile_ids.join(', ')})"] : [])

        @user_ids = (Profile.find(:all, :conditions =>[profile_conditions.join(" AND ")], :select => ["user_id"]).map{|profile| profile.user_id} - current_user.my_blocked_users.map{|bu| bu.blocked_user_id})
        if params[:has_contacted] == "1"
          @user_ids =  @user_ids - current_user.contacted_user_ids.compact
        end
        user_conditions = !@user_ids.empty? ? ["users.id IN (#{@user_ids.join(', ')})"] : []
        user_conditions << basic_search_conditions
        @users = if !@user_ids.empty?
          if pagination
            User.find(:all, :conditions => [user_conditions.join(" AND ")], :include => [:profile], :order => sort).paginate(:per_page => 10, :page => params[:page])
          else
            User.find(:all, :conditions => [user_conditions.join(" AND ")], :include => [:profile], :order => sort)
          end
        else
          [].paginate
        end
      end
    else
      user_conditions = basic_search_conditions
      @users = User.find(:all, :conditions => [user_conditions.join(" AND ")], :include => [:profile], :order => sort).paginate(:per_page => 10, :page => params[:page])
    end
  end

  def get_payment(paypal_params, credits)
    @paypal = PayPal.new(paypal_params)
    @paypal.price = PayPal.credits_to_money(credits.to_i)
    @paypal.ip_address = request.remote_ip
    @paypal.user_id = current_user.id
    return (@paypal.validate_card and @paypal.purchase)
  end

  def search_friends_to_send_message(query)
    #    role = Role.find_by_name('user')
    user_ids = User.search_for_ids "*#{query}*", :search_mode => :any, :max_matches => 100, :limit => 100
    user_ids = (user_ids - current_user.who_blocked_me.all(:select => "users.id").map{|u| u.id})
    return !user_ids.empty? ? current_user.friends.all(:conditions => ["users.id IN (#{user_ids.join(', ')})"], :select => "users.id, users.facebook_id, users.login") : []
  end

  def user_time_zone
    tzone = 'Pacific Time (US & Canada)'
    if current_user
      tzone = current_user.user_time_zone
    end
    return tzone
  end

  private

  def is_api_current_user?
    unless params[:id].to_i == current_user.id
      message = I18n.t('application.invalid_userid')
      respond_to do |format|
        format.xml { render :xml => {:message => message} }
        format.json { render :json => {:message => message} }
      end
    end
  end

  def is_api_current_user_profile?
    unless params[:user_id].to_i == current_user.id
      message = I18n.t('application.invalid_userid')
      respond_to do |format|
        format.xml { render :xml => {:message => message} }
        format.json { render :json => {:message => message} }
      end
    end
  end

  def get_api_user_columns
    profile_columns = (Profile.column_names - ["user_id", "created_at", "updated_at"]).map{|c| "profiles."+c+"#{c == 'id' ? ' AS profile_id' : ''}"}.join(', ')
    return "users.id, users.first_name, users.middle_name, users.last_name,
                      users.login, users.email, users.activated_at, users.gender, users.date_of_birth, users.zip, users.is_online, users.looking_for,
                      users.orientation, users.activation_code, users.interested_in, #{profile_columns}"
  end

  def basic_search_conditions
    i_am_a = current_user.gender
    looking_for = params[:looking_for] || 'Female'
    #    orientation = params[:orientation]
    order = params[:order] || 'Lastonline'
    role_id = Role.find_by_name('user').id
    cond = ["role_id = #{role_id}"]
    #    !params[:looking_for].to_s.blank? ? cond << "(gender = '#{params[:looking_for]}' AND users.looking_for LIKE '#{'%%'+params[:i_am_a]+'%%'}')" : ""
    if i_am_a == 'Male'
      cond << if looking_for == 'All'
        "((gender = 'Male' AND (orientation = 'Gay' OR orientation = 'Bisexual')) OR ((gender = 'Female' AND orientation = 'Straight') OR (gender = 'Male' AND orientation = 'Gay')) OR (orientation = 'Transman') OR (orientation = 'Transwoman') OR (gender = 'Female' AND (orientation = 'Straight' or orientation = 'Bisexual')))"
      elsif looking_for == 'Male'
        "(gender = 'Male' AND (orientation = 'Gay' OR orientation = 'Bisexual'))"
      elsif looking_for == 'Bisexual'
        #        "((gender = 'Male' AND orientation = 'Gay') OR (gender = 'Female' AND orientation = 'Straight') OR ((gender = 'Male' OR gender = 'Female') AND orientation = 'Bisexual'))"
        "((gender = 'Female' AND orientation = 'Straight') OR (gender = 'Male' AND orientation = 'Gay'))"
      elsif looking_for == 'Transman'
        "(orientation = 'Transman')"
      elsif looking_for == 'Transwoman'
        "(orientation = 'Transwoman')"
      else
        "(gender = 'Female' AND (orientation = 'Straight' or orientation = 'Bisexual'))"
      end
    elsif i_am_a == 'Female'
      cond << if looking_for == 'All'
        "((gender = 'Female' AND (orientation = 'Lesbian' OR orientation = 'Bisexual')) OR ((gender = 'Male' AND orientation = 'Straight') OR (gender = 'Female' AND orientation = 'Lesbian')) OR (orientation = 'Transman') OR (orientation = 'Transwoman') OR (gender = 'Male' AND (orientation = 'Straight' or orientation = 'Bisexual')))"
      elsif looking_for == 'Female'
        "(gender = 'Female' AND (orientation = 'Lesbian' OR orientation = 'Bisexual'))"
      elsif looking_for == 'Bisexual'
        #        "((gender = 'Female' AND orientation = 'Lesbian') OR (gender = 'Male' AND orientation = 'Straight') OR ((gender = 'Male' OR gender = 'Female') AND orientation = 'Bisexual'))"
        "((gender = 'Male' AND orientation = 'Straight') OR (gender = 'Female' AND orientation = 'Lesbian'))"
      elsif looking_for == 'Transman'
        "(orientation = 'Transman')"
      elsif looking_for == 'Transwoman'
        "(orientation = 'Transwoman')"
      else
        "(gender = 'Male' AND (orientation = 'Straight' or orientation = 'Bisexual'))"
      end
    elsif i_am_a == "Transman"
      cond << if looking_for == 'All'
        "((gender = 'Male' AND (orientation = 'Gay' OR orientation = 'Bisexual')) OR (gender = 'Female' AND (orientation = 'Straight' OR orientation = 'Bisexual')) OR ((gender = 'Female' AND orientation = 'Straight') OR (gender = 'Male' AND orientation = 'Gay')) OR (orientation = 'Transman') OR (orientation = 'Transwoman'))"
      elsif looking_for == 'Male'
        "(gender = 'Male' AND (orientation = 'Gay' OR orientation = 'Bisexual'))"
      elsif looking_for == 'Female'
        "(gender = 'Female' AND (orientation = 'Straight' OR orientation = 'Bisexual'))"
      elsif looking_for == 'Bisexual'
        "((gender = 'Female' AND orientation = 'Straight') OR (gender = 'Male' AND orientation = 'Gay'))"
      elsif looking_for == 'Transman'
        "(orientation = 'Transman')"
      elsif looking_for == 'Transwoman'
        "(orientation = 'Transwoman')"
      end
    elsif i_am_a == "Transwoman"
      cond << if looking_for == 'All'
        "((gender = 'Male' AND (orientation = 'Straight' OR orientation = 'Bisexual')) OR (gender = 'Female' AND (orientation = 'Lesbian' OR orientation = 'Bisexual')) OR (orientation = 'Transman') OR (orientation = 'Transwoman'))"
      elsif looking_for == 'Male'
        "(gender = 'Male' AND (orientation = 'Straight' OR orientation = 'Bisexual'))"
      elsif looking_for == 'Female' or looking_for == 'Bisexual'
        "(gender = 'Female' AND (orientation = 'Lesbian' OR orientation = 'Bisexual'))"
      elsif looking_for == 'Transman'
        "(orientation = 'Transman')"
      elsif looking_for == 'Transwoman'
        "(orientation = 'Transwoman')"
      end
    end
    if (i_am_a == 'Male' and looking_for == 'Female') or (i_am_a == 'Female' and looking_for == 'Male')
      cond << "(dont_show_me_to_straight_users = false)"
    end
    if order == 'Newest'
      from = (Date.today-14).to_time.strftime('%Y-%m-%d 00:00:00')
      to = Date.today.to_time.strftime('%Y-%m-%d 00:00:00')
      cond << "(users.activated_at >= '#{from}' AND users.activated_at <= '#{to}')"
    elsif order == 'Closest' and (current_user and current_user.user_location and !current_user.user_location.lat.to_s.blank? and !current_user.user_location.lat.to_s.blank?)
      user_ids = UserLocation.get_nearby_locations(current_user.user_location.lat, current_user.user_location.lng).map{|location| location.user_id}.uniq
      cond << "(users.id IN (#{user_ids.join(', ')}))" if !user_ids.to_a.empty?
    elsif order == 'Lastonline'
      cond << "('users.last_login_at DESC')"
    end
    if params[:free] == 'on'
      cond << "(users.available_today = true AND profiles.user_id != #{current_user.id})"
    end
    !params[:age_from].to_s.blank? ? cond << "date_of_birth  <= '#{Date.today - (364 * params[:age_from].to_i)}'" : ""
    !params[:age_to].to_s.blank? ? cond <<  "date_of_birth  >= '#{Date.today - (364 * params[:age_to].to_i)}'" : ""
    if params[:distanse] != '' and params[:zip_code] != 'Unlimited' and params[:zip_code] != '' and params[:zip_code] != 'Zip/postal code'
      zip_codes = ZipCode.get_zip_codes(params[:distance], params[:zip_code])
      cond << "zip IN (#{zip_codes.join(', ')})" if !zip_codes.empty?
    end
    if current_user
      cond << "(0 = (select count(id) from blocked_users where user_id = #{current_user.id} and blocked_user_id = users.id) AND 0=(select count(id) from blocked_users where user_id = users.id and blocked_user_id = #{current_user.id}))"
      cond << "(users.id != #{current_user.id})"
    end
    if params[:online_only]
      #      cond << "is_online = true"
      cond << "(users.last_accessed_at >= '#{5.minutes.ago.strftime("%Y-%m-%d %H:%M:%S")}' AND users.is_online = true)"
    end
    #    if params[:new_members]
    #      from = (Date.today-14).to_time.strftime('%Y-%m-%d 00:00:00')
    #      to = Date.today.to_time.strftime('%Y-%m-%d 00:00:00')
    #      cond << "(activated_at >= '#{from}' AND activated_at <= '#{to}')"
    #    end
    #    if params[:nearest_users] == 'on' and (current_user and current_user.user_location and !current_user.user_location.lat.to_s.blank? and !current_user.user_location.lat.to_s.blank?)
    #      user_ids = UserLocation.get_nearby_locations(current_user.user_location.lat, current_user.user_location.lng).map{|location| location.user_id}.uniq
    #      cond << "(users.id IN (#{user_ids.join(', ')}))" if !user_ids.to_a.empty?
    #    end
    return cond
  end

  # Will convert 24 hrs time to 12 hrs time. EX: convert('13') returns '1 PM'
  def convert_24_to_12(tym)
    if tym.to_i == 0
      return '12 AM'
    elsif tym.to_i == 12
      return '12 PM'
    else
      return (tym.to_i > 12) ? ((tym.to_i - 12).to_s + ' PM') : (tym.to_s + ' AM')
    end
  end

  def is_my_api_album?
    @album = Album.find((params[:album_id] ? params[:album_id] : params[:id]))
    unless current_user.id == @album.user_id
      response_message = {:error => I18n.t('user.general_error')}
      respond_to do |format|
        format.xml { render :xml => response_message }
        format.json { render :json => response_message }
      end
      return
    end
  end

end
