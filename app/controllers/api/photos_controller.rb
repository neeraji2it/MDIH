class Api::PhotosController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth
  before_filter :is_my_api_album?, :only => [:create, :make_album_cover]
  before_filter :is_my_photo?, :only => [:make_album_cover, :destroy]

  def index
    @album = Album.find(params[:album_id])
    @photos = @album.photos
    @photos.collect{|photo|
      photo['image-url'] = photo.image.url
      photo['image-url-medium'] = photo.image.url(:medium)
      photo['image-url-tumbnail'] = photo.image.url(:small)
      }
    respond_to do |format|
      format.xml { render :xml => @photos }
      format.json { render :json => @photos }
    end
  end

  #  curl -u login:password http://localhost.com/api/users/13/albums/9/photos.xml -X POST -F image=@/home/neeraj/Pictures/fb.jpg
  def create
    @photo = Photo.new(:image => params[:image], :user_id => current_user.id, :album_id => params[:album_id])
    if @photo.save
      response_message = {:message => I18n.t('photo.photo_upload')}
    else
      response_message = @photo.errors
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  #    curl -u login:password http://localhost.com/api/users/13/albums/9/photos/47.xml -X DELETE
  def destroy
    if @photo.destroy
      response_message = {:message => I18n.t('photo.destroy.notice')}
    else
      response_message = {:error => I18n.t('photo.destroy.error')}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  #  curl -u login:password http://localhost.com/api/users/13/albums/9/photos/45/make_album_cover.xml
  def make_album_cover
    @album = Album.find(params[:album_id])
    if @album.update_attributes(:cover_photo_id => params[:id])
      response_message = {:message => I18n.t('photo.make_album_cover.notice')}
    else
      response_message = {:error => I18n.t('photo.make_album_cover.error')}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  #  curl -u login:password http://localhost.com/api/users/13/albums/9/photos/24/comments.xml
  def comments
    @photo = Photo.find(params[:id])
    comments = @photo.photo_comments
    comments.collect{|comment| comment.get_commenter}
    respond_to do |format|
      format.xml { render :xml => comments }
      format.json { render :json => comments }
    end
  end

  # curl -u login:password http://localhost.com/api/users/13/albums/9/photos/24/post_comment.xml -X POST -d 'comment=Hi from API'
  def post_comment
    @photo_comment = PhotoComment.new(:comment => params[:comment], :user_id => current_user.id, :photo_id => params[:id])
    if @photo_comment.save
      response_message = {:message => I18n.t('photo.comment_added')}
    else
      response_message = {:error => I18n.t('photo.comment_not_posted')}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  #  curl -u login:password http://localhost.com/api/users/13/albums/9/photos/24/delete_comment.json -X DELETE -d comment_id=4
  def delete_comment
    @photo_comment = PhotoComment.find(params[:comment_id]) if PhotoComment.exists?(:id => params[:comment_id])
    if @photo_comment and @photo_comment.photo.user_id == current_user.id and @photo_comment.destroy
      response_message = {:message => I18n.t('photo.delete_comment.comment_deleted')}
    else
      response_message = {:error => I18n.t('photo.delete_comment.comment_delete_failed')}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # curl -u login:password http://localhost.com/api/users/13/albums/9/photos/46/report_as_inappropriate.json -X POST -d 'comment=Reporting form api'
  def report_as_inappropriate
    @photo = Photo.find(params[:id])
    @inappropriate_photo = InappropriatePhoto.new(:comment => params[:comment], :user_id => current_user.id, :photo_item_id => @photo.id, :photo_item_type => "Photo")
    if @inappropriate_photo.save
      response_message = {:message => I18n.t('photo.report_as_inappropriate.alert')}
    else
      response_message = {:error => I18n.t('photo.report_as_inappropriate.not_reported')}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end
  
  def make_profile_photo
    @photo = Photo.find(params[:id])
    status = @photo.make_user_profile_photo(current_user.id)
    if status == "Updated"
      response_message = {:message => I18n.t('photo.label.update')}
    else
      response_message = {:error => (status == "Error" ? I18n.t('photo.label.update_error') : status)}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  private

  def is_my_photo?
    @photo = Photo.find(params[:id])
    unless @photo.user.id == current_user.id
      response_message = {:error => I18n.t('user.general_error')}
      respond_to do |format|
        format.xml { render :xml => response_message }
        format.json { render :json => response_message }
      end
      return
    end
  end
end
