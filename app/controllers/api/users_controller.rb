class Api::UsersController < ApplicationController

  # Filter skipping the authentication for the following action.
  skip_before_filter :is_logged?, :only => [:create, :forgot_password, :contact_us, :feedback]
  before_filter :is_api_current_user?, :only => [:update]
  skip_before_filter :is_valid_account?, :only => [:update]
  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth

  # Will create new user and send and email to that user for confirmation
  def create
    logout_keeping_session!
    date_of_birth = (params[:user]["date_of_birth(1i)"].to_s+"-"+params[:user]["date_of_birth(2i)"].to_s+"-"+params[:user]["date_of_birth(3i)"].to_s) if params[:user]
    params[:user].delete_if{|k, v| ["date_of_birth(1i)", "date_of_birth(2i)", "date_of_birth(3i)"].include? k} if params[:user]
    @user = User.new(params[:user])
    @user.date_of_birth = date_of_birth
    params[:profile] = params[:profile] || {}
    #    @user.looking_for = params[:lookin_genders] #? params[:lookin_genders].join(',') : ""

    if params[:user] and @exist_user = User.find(:first, :conditions => ["email = ? AND activation_code IS NOT NULL", params[:user][:email]])
      @profile = @exist_user.profile || Profile.new(:user_id => @exist_user.id)
      @profile.attributes = params[:profile]
      @profile.valid?
      @exist_user.attributes = params[:user]
      @exist_user.date_of_birth = date_of_birth
      @exist_user.valid?
      @inviter = (@exist_user and Invitation.exists?(:invited_id => @exist_user.id)) ? Invitation.find_by_invited_id(@exist_user.id).user : nil
      if @profile.errors.to_a.empty? and @exist_user.errors.to_a.empty? and @exist_user.save and @profile.save
        FriendsUser.new(:user_id => @inviter.id, :friend_id =>@exist_user.id, :status => "pending").save if @inviter
        UserMailer.signup_notification(@exist_user).deliver
        message = I18n.t('user.thanks_signup')
        respond_to do |format|
          format.xml { render :xml => {:message => message} }
          format.json { render :json => {:message => message} }
        end
      else
        @profile.errors.each{|field, error|
          @exist_user.errors.add(field.to_sym, error)
        }
        @errors = {:errors => @exist_user.errors}
        respond_to do |format|
          format.xml { render :xml => @errors, :status => :unprocessable_entity }
          format.json { render :json => @errors, :status => :unprocessable_entity }
        end
      end
    else
      @user.build_profile(params[:profile])
      @user.valid?
      @user.profile.valid?
      if @user && @user.profile.errors.to_a.empty? && @user.save && UserMailer.signup_notification(@user).deliver
        message = I18n.t('user.thanks_signup')
        respond_to do |format|
          format.xml { render :xml => {:message => message} }
          format.json { render :json => {:message => message} }
        end
      else
        @user.profile.errors.each{|field, error|
          @user.errors.add(field.to_sym, error)
        }
        @errors = {:errors => @user.errors}
        respond_to do |format|
          format.xml { render :xml => @errors, :status => :unprocessable_entity }
          format.json { render :json => @errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # update user account
  def update
    @user = User.find(params[:id])
    @profile = @user.profile || Profile.new({:user_id => @user.id}.merge(params[:profile]))
    params[:profile] = params[:profile] || {}
    @profile.attributes = params[:profile]
    params[:user].delete(params[:user][:login]) if params[:user]
    @user.attributes = params[:user]
    @profile.valid?
    @user.valid?
    #@user.looking_for = params[:lookin_genders]
    if (@profile.errors.to_a.empty? and @user.errors.to_a.empty? and @user.save and @profile.save)
      message = I18n.t('user.account_update')
      respond_to do |format|
        format.xml { render :xml => {:message => message} }
        format.json { render :json => {:message => message} }
      end
    else
      @errors = {:errors => @user.errors.to_a+@user.profile.errors.to_a}
      respond_to do |format|
        format.xml { render :xml => @errors, :status => :unprocessable_entity }
        format.json { render :json => @errors, :status => :unprocessable_entity }
      end
    end
  end

  # Will allow user to request for reset password
  def forgot_password
    return unless request.post?
    @user = User.find(:first, :conditions => ["email = ? AND facebook_id IS NULL", params[:email]])
    if !params[:email].blank?
      if @user and !@user.activation_code.to_s.blank?
        error = I18n.t('user.invited_not_activated')
      else
        if @user && @user.create_reset_code && UserMailer.forgot_password(@user).deliver
          message = I18n.t('user.reset_password_email')
        else
          error = "#{params[:email].blank? ? I18n.t('user.to_reset_password') : "#{I18n.t('user.no_user_exist')} #{params[:email]}. #{I18n.t('user.correct_email')}"}"
        end
      end
    else
      error = I18n.t('user.to_reset_password')
    end
    respond_to do |format|
      format.xml { render :xml => message ? {:message => message} : {:error => error}}
      format.json { render :json => message ? {:message => message} : {:error => error} }
    end
  end

  # display user account details
  def show
    #    profile_columns = (Profile.column_names - ["user_id", "created_at", "updated_at"]).map{|c| "profiles."+c+"#{c == 'id' ? ' AS profile_id' : ''}"}.join(', ')
    if User.exists?(:id => params[:id])
      @user = User.find(:first, :joins => "LEFT JOIN profiles ON profiles.user_id = users.id", :conditions => ["users.id = #{params[:id]}"],
        :select => get_api_user_columns)
      @user['display_height'] = ((@user.height_units.to_s == 'Centimeters') ? @user.height.to_s+" cm" : (!@user.height.to_s.blank? ? display_cm_to_inches(@user.height).to_s+" inch" : ""))
#      @user['display_weight'] = ((@user.weight_units.to_s == 'Pounds') ? @user.weight.to_s+" lbs" : (!@user.weight.to_s.blank? ? pounds_to_kgs(@user.weight).to_s+" kgs" : ""))
      @user['location'] = @user.profile_address
      if @user.id != current_user.id
        if @profile_viewer = ProfileViewer.find(:first, :conditions =>["user_id = #{params[:id]} AND viewed_by = #{current_user.id}"])
          @profile_viewer.update_attributes(:viewed_at => Time.now)
        else
          ProfileViewer.new(:user_id => params[:id], :viewed_by => current_user.id, :viewed_at => Time.now).save
        end
      end
      respond_to do |format|
        format.xml { render :xml => @user }
        format.json { render :json => @user }
      end
    else
      error = I18n.t('user.user_not_existed_id')
      respond_to do |format|
        format.xml { render :xml => {:error => error} }
        format.json { render :json => {:error => error} }
      end
    end
  end

  def add_to_my_match
    if MyMatch.exists?(:user_id => current_user.id, :matcher_id => params[:id])
      @my_match = MyMatch.find(:first, :conditions => ["user_id = #{current_user.id} AND matcher_id = #{params[:id]}"])
      @my_match.match_percent = params[:match_percent].to_i
    else
      @my_match = MyMatch.new(:user_id => current_user.id, :matcher_id => params[:id], :match_percent => params[:match_percent])
    end
    if @my_match.save
      message = I18n.t('user.added_user_match_list')
      respond_to do |format|
        format.xml { render :xml => {:message => message} }
        format.json { render :json => {:message => message} }
      end
    else
      error = I18n.t('user.adding_user_match_list_failed')
      respond_to do |format|
        format.xml { render :xml => {:error => error} }
        format.json { render :json => {:error => error} }
      end
    end
  end

  def my_matches
    @sort = params[:sort] ? params[:sort] : 'created_at'
    @by = params[:by] ? params[:by] : 'DESC'
    #    @matched_users = current_user.my_match_users.all(:joins => "LEFT JOIN users ON users.id = my_matches.matcher_id LEFT JOIN profile_viewers ON profile_viewers.viewed_by = users.id AND profile_viewers.user_id = #{current_user.id}", :select => "my_matches.matcher_id, my_matches.match_percent, users.*, profile_viewers.viewed_at AS last_viewed_me", :order => "my_matches.created_at DESC")
    @matched_users = User.find(:all, :select => "my_matches.matcher_id, my_matches.match_percent, users.*, profile_viewers.viewed_at AS last_viewed_me", :joins => "LEFT JOIN my_matches ON my_matches.matcher_id = users.id LEFT JOIN profile_viewers ON profile_viewers.viewed_by = users.id AND profile_viewers.user_id = #{current_user.id}", :conditions => ["my_matches.user_id = #{current_user.id}"], :order => "my_matches.created_at DESC")
    @matched_users.collect{|matched_user| matched_user.basic_profile_info }
    respond_to do |format|
      format.xml { render :xml => @matched_users }
      format.json { render :json => @matched_users }
    end
  end

  def delete_from_my_match
    @match_user = MyMatch.find(:first, :conditions => ["matcher_id = ? AND user_id = ?", params[:id], current_user.id])
    if @match_user and @match_user.destroy
      respond_to do |format|
        message = I18n.t('user.delete_match')
        format.xml { render :xml => {:message => message} }
        format.json { render :json => {:message => message} }
      end
    else
      error = I18n.t('user.error_delete_match')
      respond_to do |format|
        format.xml { render :xml => {:error => error} }
        format.json { render :json => {:error => error} }
      end
    end
  end

  def recharge_credits
    if params[:credits].to_i > 0
      address_errors = []
      ['address', 'city', 'state', 'zip', 'country'].each do |field|
        address_errors << field.capitalize+ " required" if params[field].to_s.blank?
      end
      begin
        payment_details = {"card_verification"=>params[:card_verification], "card_type"=>params[:card_type], "card_number"=>params[:card_number], "card_expires_on"=>(params[:card_expires_on_month]+'/01/'+params[:card_expires_on_year]).to_date, "last_name"=>params[:last_name], "first_name"=>params[:first_name], :address => params[:address], :city => params[:city], :state => params[:state], :zip => params[:zip], :country => params[:country]}
        if address_errors.empty? and get_payment(payment_details, params[:credits].to_i)
          current_user.update_attribute(:credits, (params[:credits].to_f+current_user.credits.to_f))
          return_response = {:message => I18n.t('user.recharge_credits')}
        else
          if !address_errors.empty?
            errors = address_errors.join(", ")
          else
            errors = @paypal.errors['base']
          end
          return_response = {:error => errors.to_s.blank? ? I18n.t('user.recharge_credit_fail') : errors}
        end
      rescue Exception => e
        logger.info ">>>>>>>>>> Recharge credits"
        logger.info e
        return_response = {:error => I18n.t('user.exception')}
      end
    else
      return_response = {:error => I18n.t('user.number_of_credits')}
    end
    respond_to do |format|
      format.xml { render :xml => return_response }
      format.json { render :json => return_response }
    end
  end

  #  curl -u nagarjuna:nagarjuna http://localhost.com/api/users/recharge_credits.xml -X POST -d 'credits=20' -d 'card_expires_on_month=02'
  #  -d 'card_expires_on_year=2015' -d 'card_number=5404364291621580' -d 'first_name=Nagarjuna' -d 'last_name=R' -d 'card_verification=123'
  #  -d 'country=id' -d 'address=Bangalore' -d 'city=Bangalore' -d 'state=Karnataka' -d 'zip=12345'
  def recent_actions
    @recent_actions = User.recent_notifications(current_user.id)
    respond_to do |format|
      format.xml { render :xml => @recent_actions }
      format.json { render :json => @recent_actions }
    end
  end

  def visitors
    #    @users = current_user.profile_viewed_by(:joins => "LEFT JOIN profiles ON profiles.user_id = users.id", :select => "users.*, profile_viewers.viewed_at, profiles.city, profiles.state, profiles.country")
    @users = User.find(:all, :joins => "INNER JOIN `profile_viewers` ON `users`.id = `profile_viewers`.viewed_by", :select => "users.*, profile_viewers.viewed_at", :conditions => ["profile_viewers.user_id = #{current_user.id}"], :order => "viewed_at DESC")
    @users.collect{|user| user.basic_profile_info }
    respond_to do |format|
      format.xml { render :xml => @users }
      format.json { render :json => @users }
    end
  end

  # Displays all users visited by current user
  def visited
    #    @users = current_user.profile_viewed(:joins => "LEFT JOIN prodiles ON profiles.user_id = users.id",:select => "users.*, profile_viewers.viewed_at, profiles.city, profiles.state, profiles.country")
    @users = User.find(:all, :joins => "INNER JOIN `profile_viewers` ON `users`.id = `profile_viewers`.user_id", :select => "users.*, profile_viewers.viewed_at", :conditions => ["profile_viewers.viewed_by = #{current_user.id}"], :order => "viewed_at DESC")
    @users.collect{|user| user.basic_profile_info }
    respond_to do |format|
      format.xml { render :xml => @users }
      format.json { render :json => @users }
    end
  end

  def contact_us
    message = {}
    message.merge!({:full_name => I18n.t('home.contact_us.fullname_error')})  if params[:full_name].to_s.blank?
    message.merge!({:email => I18n.t('home.contact_us.email_error')})  if params[:email].to_s.blank?
    message.merge!({:email => I18n.t('user.invalid_email')})  if !params[:email].to_s.blank? and !Authentication.email_regex.match(params[:email])
    message.merge!({:subject => I18n.t('home.contact_us.subject_error')})  if params[:subject].to_s.blank?
    message.merge!({:message => I18n.t('home.contact_us.message_error')})  if params[:message].to_s.blank?
    if message.empty?
      if UserMailer.send_contact_form(params[:full_name], params[:email], params[:subject], params[:message]).deliver
        message = {:message => I18n.t('home.contact_us.notice')}
      else
        message = {:error => I18n.t('home.contact_us.error')}
      end
    end
    respond_to do |format|
      format.xml { render :xml => message }
      format.json { render :json => message }
    end
  end

  def feedback
    @feedback = Feedback.new(params[:feedback])
    if @feedback.save
      FeedbackMailer.feedback(@feedback).deliver
      message = {:message => I18n.t('feedback.thankyou')}
    else
      message = @feedback.errors
    end
    respond_to do |format|
      format.xml { render :xml => message }
      format.json { render :json => message }
    end
  end
end

