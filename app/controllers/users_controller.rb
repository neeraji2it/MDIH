class UsersController < ApplicationController

  include YacaphHelper

  # Filter skipping the authentication for the following action.
  skip_before_filter :is_logged?, :only => [:new, :signup_step1, :create, :signup_step2, :forgot_password, :reset_password, :activate, :accept_invitation, :deactivate_account, :reactivate_account, :reactivate, :resend_activation_email]
  #  before_filter :is_current_user?, :only => [:edit, :update, :delete_account]
  skip_before_filter :is_valid_account?, :only => [:edit, :update]
  # render new.rhtml
  layout :get_layout
  
  def new
    @user = User.new
    if request.xhr?
      render :partial => "new", :layout => false
    else
      @show_signup_form = true
      render :template  => 'home/general_home'
    end
  end

  # Will create new user and send and email to that user for confirmation
  def create_old
    logout_keeping_session!
    @user = User.new(params[:user])
    if yacaph_validated? # verify_recaptcha(@user)
      @user.looking_for = params[:lookin_genders] ? params[:lookin_genders].join(',') : ""
      if @exist_user = User.find(:first, :conditions => ["email = ? AND activation_code IS NOT NULL", params[:user][:email]])
        flash[:error] = I18n.t('user.create_old.error')
        render :update do |page|
          page.redirect_to accept_invitation_users_path(:activation_code => @exist_user.activation_code, :email => @exist_user.crypted_email)
          #        return
        end
      else
        if @user && @user.save && UserMailer.deliver_signup_notification(@user)
          flash[:notice] = I18n.t('user.create_old.notice')
          render :update do |page|
            page.redirect_to "/"
          end
        else
          render :update  do |page|
            page.replace_html 'popup_body',  render(:partial => 'new', :layout => false)
          end
        end
      end
    else
      @recaptcha_error = I18n.t('user.create_old.captcha_error')
      render :update  do |page|
        page.replace_html 'popup_body',  render(:partial => 'new', :layout => false)
      end
    end
  end

  def signup_step1
    session[:new_user_fields] = params[:user].merge({:interested_in => params[:interested_in].to_a.join(',')})
    @user = User.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @user = User.new(params[:user].merge(session[:new_user_fields]))
    if @exist_user = User.find(:first, :conditions => ["email = ? AND (activation_code IS NOT NULL AND activation_code != '')", params[:user][:email]]) and @exist_user and Invitation.exists?(:invited_id => @exist_user.id)
      flash[:error] = I18n.t('user.create_old.error')
      render :update do |page|
        page.redirect_to accept_invitation_users_path(:activation_code => @exist_user.activation_code, :email => @exist_user.crypted_email)
      end
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def signup_step2
    respond_to do |format|
      format.js
    end
  end

  # Activates the user
  def activate
    @user = User.find_by_activation_code(params[:activation_code])
    @user.update_attributes(:is_online => true, :last_login => Time.now)
    if @user && !@user.login.to_s.blank? && @user.delete_activation_code && UserMailer.activation_notification(@user).deliver
      flash[:notice] = I18n.t('user.account_activation')
      self.current_user = @user
      redirect_to edit_user_path(current_user)
    else
      flash[:error] = I18n.t('user.invalid_link')
      redirect_to "/"
    end
  end

  # Will allow user to request for reset password
  def forgot_password
    @user = User.find(:first, :conditions => ["email = ?", params[:email].strip])
    if params[:email].present? and @user and @user.facebook_id.nil?
      if @user and !@user.activation_code.to_s.blank?
        flash[:error] = I18n.t('user.invited_not_activated')
        render :js => "window.location.pathname='#{accept_invitation_users_path(:activation_code => @user.activation_code, :email => @user.crypted_email)}'"
        return
      else
        @status = true
        if @user && @user.create_reset_code && UserMailer.forgot_password(@user).deliver
          @flash_message = "<div class='notice'>#{I18n.t('user.reset_password_email')}</div>".html_safe
        else
          @flash_message = "<div class='error'>"+"#{params[:email].blank? ? I18n.t('user.to_reset_password') : "#{I18n.t("user.no_user_exist")} #{params[:email]}. #{I18n.t('user.correct_email')} ."}"+"</div>".html_safe
        end
      end
    else
      @status = false
      @flash_message = ("<div class='error'>"+"#{params[:email].blank? ? I18n.t('user.to_reset_password') : "#{I18n.t("user.no_user_exist")} #{params[:email]}. #{I18n.t('user.correct_email')} ."}"+"</div>").html_safe
    end
    respond_to do |format|
      format.js
    end
  end

  # Function allowing to reset the password of the current user after to have received a reset link in an email
  #
  # Usage URL
  #
  # /reset_password/:reset_code
  def reset_password
    @reset_code = params[:reset_code]
    if (@user = User.find_by_password_reset_code(params[:reset_code]))
      if request.post?
        @user.errors.add(:password, I18n.t('user.label.cantb_blank')) if params[:user].nil? or params[:user][:password].blank?
        @user.errors.add(:password_confirmation,I18n.t('user.label.cantb_blank')) if params[:user].nil? or params[:user][:password_confirmation].blank?
        @user.errors.add(:password, I18n.t('user.label.doesnt_match')) if params[:user].nil? or (params[:user][:password].to_s != params[:user][:password_confirmation])
        if @user.errors.empty?
          @user.password = params[:user][:password]
          @user.password_confirmation = params[:user][:password_confirmation]
        end
        if @user.errors.empty? && @user.save(:validate => false)
          @user.delete_reset_code
          flash[:notice] = I18n.t('user.password_change')
          redirect_to "/"
        else
          flash.now[:error] = I18n.t('user.password_change_failed')
          render :action => "reset_password"
        end
      end
    else
      flash[:error] = I18n.t('user.invalid_link')
      redirect_to "/"
    end
  end

  # display user account details
  def show
    @user =  User.find(params[:id])
    if @user and !request.xhr?
      if @user.id != current_user.id
        if @profile_viewer = ProfileViewer.find(:first, :conditions =>["user_id = #{@user.id} AND viewed_by = #{current_user.id}"])
          @profile_viewer.update_attributes(:viewed_at => Time.now)
        else
          ProfileViewer.new(:user_id => @user.id, :viewed_by => current_user.id, :viewed_at => Time.now).save
        end
        UserMailer.profile_notification(current_user, @user).deliver  if !request.xhr?
      end
    else
      #      flash[:error] = I18n.t('user.invalid_url')
      #      redirect_to "/"
    end
    render :partial => "user_details", :layout => false if request.xhr?
  end

  # edit user account details
  def edit
    @user = current_user #User.find(params[:id])
  end

  # update user account
  def update
    @user = current_user #User.find(params[:id])
    @user.interested_in = params[:interested] ? params[:interested].join(',') : ""
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t('user.account_update')
      #      redirect_to user_path(@user)
      redirect_to edit_user_path(@user)
    else
      flash.now[:error] = I18n.t('user.account_update_fail')
      render :action => "edit"
    end
  end

  def hot_vote
    @saved = false
    @user = begin User.find(params[:id]) rescue nil end
    if @user
      if !HotVote.exists?(:user_id => current_user.id, :hoter_id => @user.id)
        @hot_vote = HotVote.new(:user_id => current_user.id, :hoter_id => @user.id)
        if @hot_vote.save
          @saved = true
          if HotVote.exists?(:user_id => @user.id, :hoter_id => current_user.id)
            UserMailer.hot_vote_notification(current_user, @user).deliver if !@user.email.to_s.blank? and !EmailSetting.exists?(:user_id => @user.id, :alert_type => 'hot_votes', :status => false)
            UserMailer.hot_vote_notification(@user, current_user).deliver if !current_user.email.to_s.blank? and !EmailSetting.exists?(:user_id => !current_user.id, :alert_type => 'hot_votes', :status => false)
          end
          @message = "<span style='color:green'>#{I18n.t('user.votes')}<span>"
        else
          @message = I18n.t('user.please_try')
        end
      else
        @message = I18n.t('user.voted')
      end
    else
      @message = I18n.t('user.please_try')
    end
    respond_to do |format|
      format.js
    end
  end

  def accept_invitation
    @user = User.find(:first, :conditions => ["activation_code = ? AND crypted_email = ?", params[:activation_code], params[:email]])
    unless @user
      flash[:error] = I18n.t('user.invalid_url')
      redirect_to "/"
      return
    end
    @inviter = (@user and Invitation.exists?(:invited_id => @user.id)) ? Invitation.find_by_invited_id(@user.id).user : nil
    if request.put?
      if yacaph_validated? #verify_recaptcha(@user)
        if @user.update_attributes(params[:user])
          @user.delete_activation_code
          UserMailer.deliver_activation_notification(@user)
          FriendsUser.create(:user_id => @user.id, :friend_id => @inviter.id , :status => 'accepted')
          FriendsUser.create(:user_id => @inviter.id, :friend_id => @user.id , :status => 'accepted')
          flash[:notice] = I18n.t('user.signup_success')+ (@inviter ? "and #{@inviter.full_name} #{I18n.t('user.added_friend_list')}" : "")
          redirect_to "/"
        end
      else
        @recaptcha_error = I18n.t('user.create_old.captcha_error')
      end
    end
  end

  def email_settings
    #    @alert_types = current_user.email_settings.all(:conditions => ["status = 0"]).map{|setting| setting.alert_type}
    @user = current_user
    if request.post?
      system_alert_types = ['messages','chats', 'hot_votes', 'gifts', 'animations', 'popups', 'advertisements', 'chat', 'push_notifications']
      unchecked_alert_types = system_alert_types - params[:alert_types].to_a.to_a.uniq
      checked_alert_types = system_alert_types - unchecked_alert_types
      for unchecked_alert_type in unchecked_alert_types
        setting = EmailSetting.find(:first, :conditions => ["user_id = ? AND alert_type = ?", current_user.id, unchecked_alert_type])
        if setting
          setting.update_attributes(:status => false)
        else
          EmailSetting.create(:user_id => current_user.id, :alert_type => unchecked_alert_type, :status => false)
        end
      end
      for checked_alert_type in checked_alert_types
        EmailSetting.delete_all(:user_id => current_user.id, :alert_type => checked_alert_type)
      end
      if params[:time].present?
        @user.update_attributes({
            :rest_time => Time.now + params[:time].to_i.hours,
            :available_today => params[:available].present? ? true : false,
            :rest_time_hours => params[:time]
          })
      end
      #      if @user.available_today == true
      #        users = User.find(:all , :conditions => ["zip = '#{current_user.zip}' and email != '#{current_user.email}'"]) if !current_user.zip.to_s.blank?
      #        users.each do |user|
      #          UserMailer.available_today_notification(current_user, user).deliver
      #        end
      #      end

      flash.now[:notice] = I18n.t('user.email_setting')
    end
    @alert_types = current_user.email_settings.all(:conditions => ["status = 0"]).map{|setting| setting.alert_type}
  end

  def update_free_today
    current_user.update_attributes({
        :rest_time => Time.now + 24.hours ,
        :available_today => params[:available].present? ? true : false,
        :rest_time_hours => 24
      })
    #    if current_user.available_today == true
    #      users = User.find(:all , :conditions => ["zip = '#{current_user.zip}' and email != '#{current_user.email}'"]) if !current_user.zip.to_s.blank?
    #      users.each do |user|
    #        UserMailer.available_today_notification(current_user, user).deliver
    #      end
    #    end
    #    flash[:notice] = "Your's free status has been updated."
    render :update do |page|
    end
  end
  
  def update_chat_status
    current_user.update_attribute(:chat_status,params[:chat])
    #    flash[:notice] = "Your's chat status has been changed."
    render :update do |page|
    end
  end

  def show_recharge_credits_form
    render :partial => "recharge_credits", :layout => false
  end

  def recharge_credits
    if params[:credits].to_i > 0
      params[:paypal].merge!({:card_expires_on => (params["card_expires_on"] ? (params['card_expires_on']['(2i)'].to_s+"/"+params['card_expires_on']['(3i)'].to_s+"/"+params['card_expires_on']['(1i)'].to_s).to_date : "")})
      if get_payment(params[:paypal], params[:credits].to_i)
        current_user.update_attribute(:credits, (params[:credits].to_f+current_user.credits.to_f))
        @status = true
        @message = current_user.credits.to_s
        @gift_to = params[:gift_to]
      else
        @status = false
        @message = @paypal.errors['base'].present? ? @paypal.errors['base'] : I18n.t('user.recharge_credit_fail')
      end
    else
      @status = false
      @message = I18n.t('user.number_of_credits')
    end
    respond_to do |format|
      format.js
    end
  end

  def delete_account
    if UserMailer.deactivation_instruction(current_user).deliver
      flash[:notice] = "#{I18n.t('user.account_deactivation')} #{current_user.email}"
    else
      flash[:error] = I18n.t('user.account_deactivation_fail')
    end
    redirect_to user_path(current_user)
  end

  def deactivate_account
    user = User.find_deleted_by("crypted_email = '#{params[:crypted_email]}' AND email = '#{params[:email]}'")
    status = false
    if user
      user.deleted = true
      user.deleted_at = Time.now
      status = user.save(:validate => false)
    end
    if status
      flash[:notice] = I18n.t('user.account_deactivation_success')
    else
      flash[:error] = I18n.t('user.account_deactivation_fail')
    end
    redirect_to "/"
  end

  def reactivate_account
    user = User.find_deleted_by("login = '#{params[:login]}' AND deleted = true")
    if user and UserMailer.reactivation_instruction(user).deliver
      logout_killing_session!
      flash[:notice] = "#{I18n.t('user.reactivate_account')} #{user.email}"
    else
      flash[:error] = I18n.t('user.reactivate_account_fail')
    end
    redirect_to root_path
  end

  def reactivate
    user = User.find_deleted_by("crypted_email = '#{params[:crypted_email]}' AND email = '#{params[:email]}' AND deleted = true")
    status = false
    if user
      user.deleted = false
      user.deleted_at = nil
      status = user.save(:validate => false)
    end
    if status
      flash[:notice] = "#{I18n.t('user.reactivate_account_success')} #{SITE_NAME}"
    else
      flash[:error] = I18n.t('user.reactivate_account_failed')
    end
    redirect_to "/"
  end

  def resend_activation_email
    @user = User.find(:first, :conditions => ["email = ?", params[:email].strip])
    if @user and @user.activated_at.nil?
      @message = ((@user.recreate_activation_code) ? ("<span class='notice'> #{I18n.t('user.activation_email')} #{@user.email} </span>").html_safe : I18n.t('user.activation_email_fail') )
    else
      @message = (@user ? I18n.t('user.user_already_active') : "#{I18n.t('user.no_user_exist')} '#{params[:email]}' #{I18n.t('layout.email')} ")
    end
    respond_to do |format|
      format.js
    end
  end

  def change_online_status
    user = current_user
    after_logout(user)
    render :text => true
  end

  def chat
    render :action => 'chat', :layout => false
  end
  #  private
  #
  #  def is_current_user?
  #    unless params[:id].to_s == current_user.login
  #      flash[:error] = I18n.t('user.general_error')
  #      redirect_to "/"
  #    end
  #  end
end
