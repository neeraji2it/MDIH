class ProfilesController < ApplicationController
  #  before_filter :is_current_user?, :except => [:report_inappropriate_avatar]
  before_filter :is_valid_account?, :except => [:edit_photo, :update_photo, :report_inappropriate_avatar,:show_inappropriate_dialog]
  
  # New profile form for logged in user
  def new
    @user = current_user
    if current_user.profile.nil?
      @profile = Profile.new
    else
      redirect_to edit_user_profile_path(current_user, current_user.profile)
    end
  end

  # will create profile for logged in user with given values
  def create
    assign_params_to_attributes
    @profile = Profile.new(params[:profile])
    @profile.user_id = current_user.id
    if @profile.save
      flash[:notice] = I18n.t('profile.create.notice')
      redirect_to user_path(current_user)
    else
      @user = current_user
      assing_attributes_to_params
      flash.now[:error] = I18n.t('profile.create.error')
      render :action => "new"
    end
  end

  # Editing logged in user's profile
  def edit
    @user = current_user
    @profile = current_user.profile
  end

  # Updating logged in user's profile
  def update
    @profile = current_user.profile
    assign_params_to_attributes
    if @profile.update_attributes(params[:profile])
      if params[:profile][:zip].present?
        current_user.update_attribute(:zip, params[:profile][:zip])
      end
      flash[:notice] = I18n.t('profile.update.notice')
      #      redirect_to user_path(current_user)
      redirect_to edit_user_profile_path(current_user, @profile)
    else
      @user = current_user
      assing_attributes_to_params
      flash.now[:error] = I18n.t('profile.update.error')
      render :action => "edit"
    end
  end
  # Displays all profile visitors in pagination
  def visitors
    @per_page = params[:per_page] || (current_user.profile_viewed_by.per_page || 20)
    @profile_visitors = @users = current_user.profile_viewed_by.paginate(:per_page => @per_page, :page => params[:page], :select => "users.*, profile_viewers.viewed_at")
  end

  # Displays all users visited by current user
  def visited
    @per_page = params[:per_page] || (current_user.profile_viewed.per_page || 20)
    @profile_visitors = @users = current_user.profile_viewed.paginate(:per_page => @per_page, :page => params[:page], :select => "users.*, profile_viewers.viewed_at")
  end

  def edit_photo
    @profile = current_user.profile || Profile.new
    render :partial => "edit_photo", :layout => false
  end

  def update_photo
    @profile = current_user.profile || Profile.new(:user_id => current_user.id)
    @profile.avatar = params[:profile] ? params[:profile][:avatar] : nil
    if @profile.save
      flash[:notice] = I18n.t('profile.update_photo.notice')
      render :js => "window.location.reload();"
    else
      render :action => :edit
    end
  end

  def update_headline
    @profile = current_user.profile || Profile.new(:user_id => current_user.id)
    if request.get?
      render :partial => "update_headline", :layout => false
    else
      @profile.headline = params[:profile] ? params[:profile][:headline] : nil
      render :update do |page|
        if @profile.save
          page.replace_html "user_headline_short_"+@user.id.to_s, truncate(@profile.headline.to_s, :length => 28)
          page.replace_html "user_headline_full_"+@user.id.to_s, @profile.headline.to_s
          page.call "hide_popup"
        else
          page.replace_html "popup_body", (render :partial => "update_headline", :layout => false)
        end
      end
    end
  end

  def show_inappropriate_dialog
    @profile = Profile.find(params[:id])
    render :partial => "report_inappropriate_avatar", :layout => false
  end

  def report_inappropriate_avatar
    @profile = Profile.find(params[:id])
    @inappropriate_photo = InappropriatePhoto.new(params[:inappropriate_photo].merge!({:user_id => current_user.id, :photo_item_id => @profile.id, :photo_item_type => "Profile"}))
    @status = @inappropriate_photo.save
  end

  private

  #  def is_current_user?
  #    if current_user.login != params[:user_id].to_s
  #      flash[:error] = I18n.t('user.general_error')
  #      redirect_to "/"
  #    end
  #  end

  # Will take values of language_spoken, favorite_musif, favorite_movies, facorite_activity, and interests
  # checked by user and joins into as string with saparated by coma(,) and will assign to parameters
  def assign_params_to_attributes
    params[:profile][:pets] = params[:profile][:pets].join(", ") if params[:profile][:pets]
    params[:profile][:fetish] = params[:profile][:fetish].join(", ") if params[:profile][:fetish]
    params[:profile][:favorite_sports] = params[:profile][:favorite_sports].join(", ") if params[:profile][:favorite_sports]
    params[:profile][:favorite_clubs] = params[:profile][:favorite_clubs].join(", ") if params[:profile][:favorite_clubs]
    params[:profile][:sexual_activity] = params[:profile][:sexual_activity].join(", ") if params[:profile][:sexual_activity]
    params[:profile][:favorite_food] = params[:profile][:favorite_food].join(", ") if params[:profile][:favorite_food]
    #    params[:profile][:languages_spoken] = params[:profile][:languages_spoken].join(", ") if params[:profile][:languages_spoken]
    params[:profile][:favorite_music] = params[:profile][:favorite_music].join(", ") if params[:profile][:favorite_music]
    #    params[:profile][:favorite_movies] = params[:profile][:favorite_movies].join(", ") if params[:profile][:favorite_movies]
    params[:profile][:favorite_avtivity] = params[:profile][:favorite_avtivity].join(", ") if params[:profile][:favorite_avtivity]
    params[:profile][:interests] = params[:profile][:interests].join(", ") if params[:profile][:interests]
    if params[:height_in] == 'Inches'
      params[:profile][:height_units] = 'Inches'
      params[:profile][:height] = inches_to_cm(params[:height_feets]+"."+params[:height_inches])
    else
      params[:profile][:height_units] = 'Centimeters'
      params[:profile][:height] = params[:height_cm]
    end
  end

  # This will undo of assign_params_to_attributes method
  def assing_attributes_to_params
    params[:profile][:pets] = params[:profile][:pets].split(", ") if params[:profile][:pets]
    params[:profile][:fetish] = params[:profile][:fetish].split(", ") if params[:profile][:fetish]
    params[:profile][:favorite_sports] = params[:profile][:favorite_sports].split(", ") if params[:profile][:favorite_sports]
    params[:profile][:favorite_clubs] = params[:profile][:favorite_clubs].split(", ") if params[:profile][:favorite_clubs]
    params[:profile][:sexual_activity] = params[:profile][:sexual_activity].split(", ") if params[:profile][:sexual_activity]
    params[:profile][:favorite_food] = params[:profile][:favorite_food].split(", ") if params[:profile][:favorite_food]
    #    params[:profile][:languages_spoken] = params[:profile][:languages_spoken].split(", ") if params[:profile][:languages_spoken]
    params[:profile][:favorite_music] = params[:profile][:favorite_music].split(", ") if params[:profile][:favorite_music]
    #    params[:profile][:favorite_movies] = params[:profile][:favorite_movies].split(", ") if params[:profile][:favorite_movies]
    params[:profile][:favorite_activity] = params[:profile][:favorite_activity].split(", ") if params[:profile][:favorite_activity]
    params[:profile][:interests] = params[:profile][:interests].split(", ") if params[:profile][:interests]
  end
end
