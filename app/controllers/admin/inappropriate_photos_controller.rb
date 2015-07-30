class Admin::InappropriatePhotosController < ApplicationController
  before_filter :is_admin?
  layout 'admin'

  def index
    @photos = Photo.find(:all, :conditions => ["photos.id IN (select DISTINCT(photo_item_id) from inappropriate_photos where photo_item_type = 'Photo')"]).paginate(:page => params[:page], :per_page => 20)
  end

  def show
    @photo = Photo.find(params[:id])
  end

  def destroy
    @inappropriate_photo = InappropriatePhoto.find(params[:id])
    @status = @inappropriate_photo.destroy
    respond_to do |format|
      format.js
    end
  end

  def destroy_photo
    @photo = Photo.find(params[:id])
    if @photo.destroy
      flash[:notice] = I18n.t('inappropriate_photo.destroy_photo.notice')
      redirect_to admin_inappropriate_photos_path()
    else
      flash[:error] = I18n.t('inappropriate_photo.destroy_photo.error')
      redirect_to admin_inappropriate_photo_path(@photo)
    end
  end

  def remove_photo
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(:image => File.new("#{Rails.root}/app/assets/images/removed.JPG"))
      flash[:notice] = I18n.t('inappropriate_photo.remove_photo.notice')
      @photo.inappropriate_photos.clear
      redirect_to admin_inappropriate_photos_path()
    else
      flash[:error] = I18n.t('inappropriate_photo.remove_photo.error')
      redirect_to admin_inappropriate_photo_path(@photo)
    end
  end

  def profiles
    @profiles = Profile.find(:all, :select => "id, avatar_file_name, avatar_content_type, avatar_file_size", :conditions => ["profiles.id IN (select DISTINCT(photo_item_id) from inappropriate_photos where photo_item_type = 'Profile')"]).paginate(:page => params[:page], :per_page => 20)
  end

  def profile
    @profile = Profile.find(params[:id])
  end

  def remove_profile_photo
    puts "KKKKKKKKKKKKKK"
    @profile = Profile.find(params[:id])
    if @profile.update_attributes(:avatar => File.new("#{Rails.root}/app/assets/images/removed.JPG"))
      puts "YAYAYAY!!!"
      flash[:notice] = I18n.t('inappropriate_photo.remove_profile_photo.notice')
      @profile.inappropriate_photos.clear
      redirect_to profiles_admin_inappropriate_photos_path()
    else
      puts "JJJJJJJJJJJJ"
      flash[:error] = I18n.t('inappropriate_photo.remove_profile_photo.error')
      redirect_to profile_admin_inappropriate_photo_path(@profile)
    end
  end
end

