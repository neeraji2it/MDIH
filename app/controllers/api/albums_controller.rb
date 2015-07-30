class Api::AlbumsController < ApplicationController

  before_filter :is_my_api_album?, :only => [:update, :destroy]
  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth

  # http://localhost.com/api/users/2/albums.xml
  def index
    @user = User.find(params[:user_id])
    @albums = @user.albums
    @albums.collect{|album|
      album['cover-photo'] = (album.cover_photo ? album.cover_photo.image.url : BASE_URL+"/images/empty_album.jpg")
      album['cover-photo-medium'] = (album.cover_photo ? album.cover_photo.image.url(:medium) : BASE_URL+"/images/empty_album.jpg")
      album['cover-photo-tumbnail'] = (album.cover_photo ? album.cover_photo.image.url(:small) : BASE_URL+"/images/empty_album.jpg")

      }
    respond_to do |format|
      format.xml { render :xml => @albums }
      format.json { render :json => @albums }
    end
  end

  #  curl -u login:password http://localhost.com/api/users/2/albums.xml -X POST -d 'name=API Album' -d 'description=gdsgdsd'
  def create
    @album = Album.new(:name => params[:name], :description => params[:description], :user_id => current_user.id)
    if @album.save
      response_message = {:message => I18n.t('album.create.notice')}
    else
      response_message = @album.errors
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # curl -u login:password http://localhost.com/api/users/13/albums/7.json -X PUT -d 'name=API Album2' -d 'description=gdsgdsd'

  def update
    if @album.update_attributes(:name => params[:name], :description => params[:description])
      response_message = {:message => I18n.t('album.update.notice')}
    else
      response_message = @album.errors
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # curl -u login:password http://localhost.com/api/users/13/albums/7.json -X DELETE
  def destroy
    if @album.destroy
      response_message = {:message => I18n.t('album.destroy.notice')}
    else
      response_message = {:errors => I18n.t('album.error_delete')}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end


end
