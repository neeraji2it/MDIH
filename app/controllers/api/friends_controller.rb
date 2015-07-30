class Api::FriendsController < ApplicationController
  # Filter skipping the authentication for the following action.
  skip_before_filter :is_valid_account?
  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth

  def index
    @user = User.find(:first, :conditions => ["id = ? ", params[:user_id]])
    if @user
      @users = @user.friends.all(:joins => "LEFT JOIN profile_viewers ON profile_viewers.viewed_by = users.id AND profile_viewers.user_id = #{current_user.id}", 
        :select => "users.id, users.login, users.email, users.activated_at, users.gender, users.date_of_birth, users.zip, users.is_online, users.looking_for, users.facebook_id,
                      users.orientation, users.activation_code, profile_viewers.viewed_at AS last_viewed_me")
      @users.collect{|user| user.basic_profile_info }
    else
      @users = {:error => I18n.t('friend.invalid_user')}
    end
    respond_to do |format|
      format.xml { render :xml => @users }
      format.json { render :json => @users }
    end
  end

  def add
    message = I18n.t('user.please_try')
    if @friend = FriendsUser.find(:first, :conditions =>{:user_id => current_user.id, :friend_id => params[:id]})
      if @friend.status != "accepted"
        @friend.update_attributes(:status => "pending")
        UserMailer.friend_request_notification(current_user, @friend.friend).deliver
      end
      message = {:error => (@friend.status == "pending" ? I18n.t('friend.add.notice') : I18n.t('friend.add.notice1'))}
    else
      if @friend = User.find(:first, :conditions => ["id = ?", params[:id]])
        if FriendsUser.new(:user_id => current_user.id, :friend_id => params[:id], :status => "pending").save
          UserMailer.friend_request_notification(current_user, @friend).deliver
          message = {:message => @friend ? "#{I18n.t('friend.add.notice2')} #{@friend.display_name}" : "#{I18n.t('friend.add.notice3')}"}
        else
          message = {:error => "#{I18n.t('friend.add.error')} #{@friend.display_name} #{I18n.t('friend.add.error1')}"}
        end
      else
        message = {:error => I18n.t('friend.invalid_user')}
      end
    end
    respond_to do |format|
      format.xml { render :xml => message }
      format.json { render :json => message }
    end
  end

  
  def destroy
    if User.exists?(:id => params[:id]) and @friend = FriendsUser.find(:first, :conditions => ["user_id = ? AND friend_id = ?", current_user.id, params[:id]])
      if @friend.destroy
        message = {:message => I18n.t('friend.destroy.notice')}
      else
        message = {:error => I18n.t('friend.destroy.error')}
      end
    else
      message = {:error => I18n.t('friend.invalid_friend')}
    end
    respond_to do |format|
      format.xml { render :xml => message }
      format.json { render :json => message }
    end
  end

  def requested_friends
    @pending_friends = current_user.requested_friends.all(:select => "users.id, users.login, users.email, users.activated_at, users.gender, users.date_of_birth, users.zip, users.is_online, users.looking_for,
                      users.orientation, users.activation_code")
    @pending_friends.collect{|user| user.basic_profile_info }
    respond_to do |format|
      format.xml { render :xml => @pending_friends }
      format.json { render :json => @pending_friends }
    end
  end

  def confirm_or_ignore
    message = {:error => I18n.t('user.please_try')}
    user = User.find(:first, :conditions => ["id = ? ", params[:id]])
    if user and ["accepted", "ignored"].include?(params[:status])
      requested_friend = FriendsUser.find(:first, :conditions =>{:user_id => user.id, :friend_id => current_user.id, :status => "pending"})
      if requested_friend
        my_friend = if FriendsUser.exists?(:user_id => current_user.id, :friend_id => user.id )
          already_requested = FriendsUser.find(:first, :conditions => {:user_id => user.id, :friend_id =>  current_user.id})
          already_requested.status = params[:status]
          already_requested
        else
          FriendsUser.new(:user_id => current_user.id, :friend_id => user.id , :status => params[:status])
        end
        if requested_friend.update_attributes(:status => params[:status]) && my_friend.save
          UserMailer.confirm_or_ignore_friend_request_notification(current_user, user, params[:status]).deliver
          message = {:message => "#{params[:status].capitalize} #{I18n.t('friend.label.successfully')}"}
        end
      else
        message = {:error => I18n.t('friend.label.no_friend')}
      end
    else
      message = {:error => user ? I18n.t('friend.label.invalid_status') : I18n.t('friend.invalid_user')}
    end
    respond_to do |format|
      format.xml { render :xml => message }
      format.json { render :json => message }
    end
  end
end
