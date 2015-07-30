class Api::ProfilesController < ApplicationController
  before_filter :is_api_current_user_profile?, :only => [:update]
  before_filter :is_valid_account?, :except => [:update_photo]
  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth

  # will create profile for logged in user with given values
  def create
    assign_api_params_to_attributes
    @profile = current_user.profile || Profile.new(params[:profile])
    @profile.user_id = current_user.id
    new_record = @profile.new_record?
    if (new_record and @profile.save) or (!new_record and @profile.update_attributes(params[:profile]))
      message = (new_record ? I18n.t('profile.create.notice') : I18n.t('profile.update.notice'))
      respond_to do |format|
        format.xml { render :xml => {:message => message} }
        format.json { render :json => {:message => message} }
      end
    else
      respond_to do |format|
        format.xml { render :xml => @profile.errors }
        format.json { render :json => @profile.errors }
      end
    end
  end

  # Updating logged in user's profile
  def update
    @profile = current_user.profile
    assign_api_params_to_attributes
    if @profile.update_attributes(params[:profile])
      message = I18n.t('profile.update.notice')
      respond_to do |format|
        format.xml { render :xml => {:message => message} }
        format.json { render :json => {:message => message} }
      end
    else
      respond_to do |format|
        format.xml { render :xml => @profile.errors }
        format.json { render :json => @profile.errors }
      end
    end
  end

  def update_photo
    @profile = current_user.profile || Profile.new(:user_id => current_user.id)
    @profile.avatar = params[:profile] ? params[:profile][:avatar] : nil
    if @profile.save
      message = I18n.t('profile.update_photo.notice')
      respond_to do |format|
        format.xml { render :xml => {:message => message} }
        format.json { render :json => {:message => message} }
      end
    else
      respond_to do |format|
        format.xml { render :xml => @profile.errors }
        format.json { render :json => @profile.errors }
      end
    end

  end


  def assign_api_params_to_attributes
    if params[:height_in] == 'Inches'
      params[:profile][:height_units] = 'Inches'
      params[:profile][:height] = inches_to_cm(params[:height_feets]+"."+params[:height_inches])
    else
      params[:profile][:height_units] = 'Centimeters'
      params[:profile][:height] = params[:height_cm]
    end
  end

end
