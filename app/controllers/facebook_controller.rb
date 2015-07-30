class FacebookController < ApplicationController
  skip_before_filter :is_logged?
  before_filter :ensure_authenticated_to_facebook

  def index
    if current_facebook_user
      current_facebook_user.fetch
      @user = User.find_by_facebook_id(current_facebook_user.id)
      if @user.nil?
        location = current_facebook_user.location
        @user = User.new(
          :login => current_facebook_user.id.to_s ,
          :email => current_facebook_user.email,
          :date_of_birth => current_facebook_user.birthday.present? ? Time.parse(current_facebook_user.birthday) : nil,
          :gender => current_facebook_user.gender.to_s.capitalize,
          :status => 1,
          :activated_at => Time.now,
          :zip => location ? location.zip : nil,
          :facebook_id => current_facebook_user.id,
          :fb_small_image => current_facebook_user.sized_image_url("small"),
          :fb_big_image => current_facebook_user.sized_image_url("large"))
        @user.profile = Profile.new(:city => location ? location.city : nil,
          :state => location ? location.state : nil,
          :country => location ? location.country : nil,
          :marital_status => current_facebook_user.relationship_status,
          :interests => get_values(current_facebook_user.interests),
          :description => current_facebook_user.bio,
          :favorite_avtivity => get_values(current_facebook_user.activities),
          :favorite_music => get_values(current_facebook_user.music),
          :favorite_books =>  get_values(current_facebook_user.books),
          :favorite_movies => get_values(current_facebook_user.movies),
          :favorite_tv_show => get_values(current_facebook_user.television),
          :religion => current_facebook_user.religion)
        @user.status = 1
        #      @user.last_accessed_at = Time.now
        #      @user.last_login = Time.now
        if @user.save
          @user.update_attributes(:fb_small_image => current_facebook_user.sized_image_url("small"), :fb_big_image => current_facebook_user.sized_image_url("large"), :last_accessed_at => Time.now, :last_login => Time.now)
          @profile = @user.profile
          %x[wget -P #{Rails.root}/public/uploaded_files/facebook_profile/#{@profile.id} #{@user.fb_big_image}]
          @profile.avatar =  File.new("#{Rails.root}/public/uploaded_files/facebook_profile/#{@profile.id}/#{[@user.fb_big_image.split('/').last, '.jpg'].join}")
          @profile.save
        end
      else
        @user.update_attributes(:fb_small_image => current_facebook_user.sized_image_url("small"), :fb_big_image => current_facebook_user.sized_image_url("large"), :last_accessed_at => Time.now, :last_login => Time.now)
        #      @user.last_accessed_at = Time.now
        #      @user.last_login = Time.now
        #      @user.save
        @profile = @user.profile
      end
#      if File.exists?("#{Rails.root}/public/uploaded_files/facebook_profile/#{@profile.id}/#{@user.fb_big_image.split('/').last}")
#        FileUtils.rm_rf "#{Rails.root}/public/uploaded_files/facebook_profile/#{@profile.id}/"
#      end
      self.current_user = @user
      redirect_to :controller=>"home",:action=>"index"
    end
  end

  private
  def ensure_authenticated_to_facebook
    if current_facebook_user.nil?
      redirect_to "/"
    end
  end

  def get_values(array)
    return "" if array.blank?
    array.collect{|a| a.name}.join(", ")
  end

end
