class PhotosController < ApplicationController
  before_filter :is_my_photo?, :only => [:make_album_cover, :destroy]
  before_filter :current_object, :only => [:ajax_show]

  def new
    @album = Album.find(params[:album_id])
    @photo = Photo.new(:user_id => current_user.id, :album_id => params[:album_id])
  end

  def index
    return
  end

  def create
    @photo = Photo.new(:user_id => current_user.id, :album_id => params[:album_id])
    @photo.image = params[:photo][:path]
    if @photo.save
      puts [@photo.to_jq_upload].to_json.inspect
      respond_to do |format|
        format.html { #(html response is for browsers using iframe sollution)
          render :json => [@photo.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json {
          render :json => [@photo.to_jq_upload].to_json
        }
      end
    else
      puts "Sorry "
    end
  end

  def show
    @user = User.find(params[:user_id])
    @photo = Photo.find(params[:id])
    @album = Album.find(params[:album_id])
    @photos = @album.photos.all(:order => "created_at DESC")
  end

  def ajax_show
    render :partial => "photo_details", :layout => false
  end

  def fancy_show
    @page = (params[:page].to_i > 8 or params[:page].to_i < 0) ? 1 : params[:page]
    @user = User.find(params[:user_id])
    @photos = @user.photos.paginate(:page => @page, :per_page => 1)
    @photo = @photos.first
    respond_to do |format|
      format.js
    end
  end

  def make_album_cover
    @album = Album.find(params[:album_id])
    if @album.update_attributes(:cover_photo_id => params[:id])
      flash[:notice] = I18n.t('photo.make_album_cover.notice')
    else
      flash[:error] =  I18n.t('photo.make_album_cover.error')
    end
    redirect_to user_album_path(current_user, params[:album_id])
  end

  def destroy
    @photo = Photo.find(params[:id])
    if @photo.destroy
      flash[:notice] = I18n.t('photo.destroy.notice')
    else
      flash[:error] = I18n.t('photo.destroy.error')
    end
    if !request.xhr?
      render :text => true
    else
      render :update do |page|
        page.reload
      end
    end
  end

  def create_comment
    @photo_comment = PhotoComment.new(params[:photo_comment].merge({:user_id => current_user.id, :photo_id => params[:id]}))
    if @photo_comment.save
      @photo = Photo.find(params[:id])
      render :update do |page|
        page.replace_html "photo_comments", (render :partial => "comments")
        page.replace_html "photo_comment_status", ""
        page << "jQuery('#photo_comment_comment').val('')"
      end
    else
      render :update do |page|
        page.replace_html "photo_comment_status", "<span style='color:red'>#{@photo_comment.errors['comment'].class.to_s == 'Array' ? @photo_comment.errors['comment'].join(', ') : @photo_comment.errors['comment'] }</span>"
      end
    end
  end

  def post_comment
    @photo_comment = PhotoComment.new(params[:photo_comment].merge({:user_id => current_user.id, :photo_id => params[:id]}))
    if @photo_comment.save
      @photo = Photo.find(params[:id])
      render :update do |page|
        page.replace_html "photo_comments", (render :partial => "fancy_comments")
        page.replace_html "photo_comment_status", "<span style='color:green'>#{I18n.t('photo.post_comment.comment_created')}</span>"
        page << "jQuery('#photo_comment_comment').val('')"
      end
    else
      render :update do |page|
        page.replace_html "photo_comment_status", "<span style='color:red'>#{@photo_comment.errors['comment'].class.to_s == 'Array' ? @photo_comment.errors['comment'].join(', ') : @photo_comment.errors['comment'] }</span>"
      end
    end
  end

  def delete_comment
    @photo_comment = PhotoComment.find(params[:id])
    if @photo_comment.photo.user_id == current_user.id and @photo_comment.destroy
      render :update do |page|
        page.remove "comment_"+params[:id]
        page.replace_html "comment_status", "<span style ='color:green;'>#{I18n.t('photo.delete_comment.comment_deleted')}</span>"
      end
    else
      render :update do |page|
        page.replace_html "comment_status", "<span style ='color:red;'>#{I18n.t('photo.delete_comment.comment_delete.failed')}</span>"
      end
    end
  end

  def show_photo_inappropriate_form
    @photo = Photo.find(params[:id])
    @inappropriate_photo = InappropriatePhoto.new
    render :partial => "report_as_inappropriate", :layout => false
  end

  def report_as_inappropriate
    @photo = Photo.find(params[:id])
    @inappropriate_photo = InappropriatePhoto.new(params[:inappropriate_photo].merge!({:user_id => current_user.id, :photo_item_id => @photo.id, :photo_item_type => "Photo"}))
    @status = @inappropriate_photo.save
    respond_to do |format|
      format.js
    end
  end

  def make_profile_photo
    @photo = Photo.find(params[:id])
    status = @photo.make_user_profile_photo(current_user.id)
    if status == "Updated"
      flash[:notice] = I18n.t('photo.label.update')
    else
      flash[:error] = (status == "Error" ? I18n.t('photo.label.update_error') : status)
    end
    #    redirect_to user_album_photo_path(@photo.album.user, @photo.album, @photo)
    redirect_to user_album_path(current_user, params[:album_id])
  end

  private

  def is_my_photo?
    @photo = Photo.find(params[:id])
    unless @photo.user.id == current_user.id
      flash[:error] = I18n.t('user.general_error')
      redirect_to "/"
    end
  end

  def current_object
    @user = User.find(params[:user_id])
    @photo = Photo.find(params[:id])
    @album = Album.find(params[:album_id])
    @photos = @album.photos.all(:select => 'id',:order => "created_at DESC")
    @photos.each_index do |page|
      if @photos.length > 2 and @photos[page].id == @photo.id
        if page == 0
          @next = @photos[page+1].id
        elsif page == @photos.length - 1
          @previous = @photos[page-1].id
        else
          @previous = @photos[page-1].id
          @next = @photos[page+1].id
        end
      end
    end
  end
end

