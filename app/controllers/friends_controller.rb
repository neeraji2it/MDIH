class FriendsController < ApplicationController

  # GET /users/:user_id/friends
  # GET /users/:user_id/friends.xml
  def index
    @user =  begin User.find(params[:user_id]) rescue nil end
    if @user
      @users = if params[:sort].to_s.blank? or params[:sort] == "Newest"
        @user.friends.order("friends_users.created_at DESC").paginate(:per_page => 5, :page => params[:page])
      elsif params[:sort] == "Oldest"
        @user.friends.order("friends_users.created_at ASC").paginate(:per_page => 5, :page => params[:page])
      elsif params[:sort] == "Lastonline"
        @user.friends.order("users.last_login_at DESC").paginate(:per_page => 5, :page => params[:page])
      elsif params[:sort ] == "online"
        @user.friends.where("users.is_online = true and users.last_accessed_at > '#{5.minutes.ago}'").paginate(:per_page => 5, :page => params[:page])
      else
        @user.friends.order("friends_users.created_at DESC").paginate(:per_page => 5, :page => params[:page])
      end
      respond_to do |format|
        format.html { render :partial => 'ajax_friends', :layout => false if request.xhr?}
        format.xml  { render :xml => @friends }
      end
    else
      flash[:error] = I18n.t('friend.invalid_user')
      redirect_to user_friends_path(current_user)
    end
  end

  def online_friends
    @user =  begin User.find(params[:user_id]) rescue nil end
    if @user
      @users = @user.friends.where("(users.is_online = true and users.last_accessed_at > '#{5.minutes.ago}') or available_today = true")
    end
    render :partial => 'friends', :layout => false if request.xhr?
  end

  # DELETE /friends/1
  # DELETE /friends/1.xml
  def destroy
    user = begin User.find(params[:id]) rescue nil end
    @friend = FriendsUser.find(:first, :conditions => ["user_id = ? AND friend_id = ?", current_user.id, user.id])
    if @friend
      if @friend.destroy
        flash[:notice] = I18n.t('friend.destroy.notice')
      else
        flash[:error] = I18n.t('friend.destroy.error')
      end
    else
      flash[:error] = I18n.t('user.general_error')
    end
    redirect_to user_friends_path(current_user)
  end

  # add user as friend
  def add
    @user =  begin User.find(params[:id]) rescue nil end
    @saved = false
    if @user
      if @friend = FriendsUser.find(:first, :conditions =>{:user_id => current_user.id, :friend_id => @user.id})
        if  @friend.status != "accepted"
          @friend.update_attribute(:status, "accepted") if FriendsUser.exists?(:user_id => current_user.id, :friend_id => @user.id )
          @message = flash[:notice] =  "You have added #{@user.display_name} as a favorite"
        else
          @message = flash[:notice] =  I18n.t('friend.add.notice1')
        end
      else
        @friend = User.find(params[:id]) if User.exists?(:id => @user.id)
        if FriendsUser.new(:user_id => current_user.id, :friend_id => @user.id, :status => "accepted").save
          @saved = true
          #          UserMailer.friend_request_notification(current_user, @friend).deliver
          @message = flash[:notice] = @friend ? "You have added #{@friend.display_name} as a favorite" : I18n.t('friend.add.notice3')
        else
          @message =  flash[:error] = "#{I18n.t('friend.add.error')} #{@friend.display_name} #{I18n.t('friend.add.error1')}."
        end
      end
    else
      @message = flash[:error] = I18n.t('user.general_error')
    end
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      redirect_to user_friends_path(current_user)
    end
  end

  def requested_friends
    @pending_friends = current_user.requested_friends
    render :action => "index"
  end

  def confirm_or_ignore
    user = begin User.find(params[:id]) rescue nil end
    status = false
    requested_friend = FriendsUser.find(:first, :conditions =>{:user_id => user.id, :friend_id => current_user.id, :status => "pending"})
    if requested_friend && ["accepted", "ignored"].include?(params[:status])
      my_friend = if FriendsUser.exists?(:user_id => current_user.id, :friend_id => user.id )
        already_requested = FriendsUser.find(:first, :conditions => {:user_id => user.id, :friend_id =>  current_user.id})
        already_requested.status = params[:status]
        already_requested
      else
        FriendsUser.new(:user_id => current_user.id, :friend_id => user.id , :status => params[:status])
      end
      if requested_friend.update_attributes(:status => params[:status]) && my_friend.save
        UserMailer.confirm_or_ignore_friend_request_notification(current_user, user, params[:status]).deliver
        #        div_id, message = "request_link_#{user.id.to_s }", "<p style ='color: green'>#{params[:status].capitalize}</p>"
        flash[:notice] = (params[:status] == 'accepted') ? I18n.t('friend.add.acccepted_successfully') : I18n.t('friend.add.regected_successfully')
        status = true
      else
        div_id, message = "status_#{user.id.to_s }", "<span style ='color: red;font-size: 11px;padding-bottom: 5px;'>#{I18n.t('user.please_try')}</span>"
      end
    else
      div_id, message = "request_link_#{user.id.to_s }", "<p style ='color: red'>#{I18n.t('general_word.error')}</p>"
    end
    render :update do |page|
      if status
        page.redirect_to requested_friends_user_friends_path(current_user)
      else
        page.replace_html div_id, message
      end
    end
  end

  def search
    @user_friends = search_friends_to_send_message(params[:q])
    tokens = []
    @user_friends.each do |friend|
      tokens << "{\"id\":\"#{friend.id}\", \"name\":\"#{friend.display_name}\"}"
    end

    render :text => "[#{tokens.join(",")}]"

    #    render :text => '[{"id":"856","name":"House"},
    # {"id":"1035","name":"Desperate Housewives"},
    # {"id":"1048","name":"Dollhouse"},
    # {"id":"1113","name":"Full House"}
    #]'
  end
end
