class AlbumsController < ApplicationController
  before_filter :is_my_album, :only => [:edit, :update, :destroy]
  #  before_filter :is_my_friend?

  def index
    @user = User.find(params[:user_id])
    @albums = @user.albums.paginate(:per_page => 12, :page => params[:page])
    render :partial => "ajax_albums", :layout => false if request.xhr?
  end

  def albums_popup
    @user = User.find(params[:user_id])
    @albums = @user.albums.paginate(:per_page => 4, :page => params[:page])
    if params[:page].nil?
      render :partial => "albums", :layout => false if request.xhr?
    else
      render :partial => "ajax_albums_popup", :layout => false if request.xhr?
    end
  end
  
  def new
    @album = Album.new
    render :partial => "form"
  end

  def create
    @status = false
    @album = Album.new(params[:album].merge({:user_id => current_user.id}))
    if @album.save
       @status = true
      flash[:notice] = I18n.t('album.create.notice')
      render :update do |page|
        page.redirect_to user_album_path(current_user.id, @album.id)
      end
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def show
    @user = User.find(:first, :conditions =>["login = ? OR id = ?", params[:user_id], params[:user_id]])
    @album = Album.find(params[:id])
    @photos = @album.photos.order("image_updated_at DESC").paginate(:per_page => 12, :page => params[:page])
    @photo = Photo.new(:user_id => current_user.id, :album_id => @album.id)
    render :partial => "show", :layout => false if request.xhr?
  end

  def edit
    #    @album = Album.find(params[:id])
    render :partial => "form"
  end

  def update
    #    @album = Album.find(params[:id])
    if @album.update_attributes(params[:album])
      flash[:notice] = I18n.t('album.update.notice')
      render :update do |page|
        page.redirect_to user_album_path(current_user, @album)
      end
    else
      render :update do |page|
        page.replace_html "popup_body", (render :partial => "form")
      end
    end
  end

  def destroy
    #    @album = Album.find(params[:id])
    if @album.destroy
      flash[:notice] = I18n.t('album.destroy.notice')
      redirect_to user_albums_path(current_user)
    end
  end

  private

  def is_my_album
    @album = Album.find(params[:id])
    unless current_user.id == @album.user_id
      flash[:error] = I18n.t('user.general_error')
      redirect_to "/"
      return
    end
  end
end
