class Photo < ActiveRecord::Base
  include Rails.application.routes.url_helpers


  has_attached_file :image, :styles => {:original => "760x760>",:medium => "150x150",:small => "87x116>" }, :default_url => '/images/default_avatar.jpg'
  
  def to_jq_upload
    {
#      "name" => read_attribute(:image_file_name),
#      "size" => image.size,
      "url" => image.url,
      "thumbnail_url" => image.url(:medium),
      "delete_url" => user_album_photo_path(:user_id => user.id, :album_id => album.id, :id => id),
      "delete_type" => "DELETE"
    }
  end
  
#  has_attached_file :image,
#    :storage => :s3,
#    :s3_credentials => "#{Rails.root}/config/s3.yml",
#    :path => "uploaded_files/photo/:id/:style/:basename.:extension",
#    :bucket => S3_BUCKET_NAME,
#    :styles => {
#    :original => "760x760>",
#    :medium => "150x150",
#    :small => "87x116>" }

  # Validation of the presence of an attached file
  validates_attachment_presence :image
  validates_attachment_content_type :image, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp', 'image/x-png', 'image/pjpeg']
	# Validation of the size of the attached file
  validates_attachment_size(:image, :less_than => 10.megabytes)

  belongs_to :user
  belongs_to :album
  has_many :photo_comments, :dependent => :destroy
#  has_many :inappropriate_photos, :dependent => :destroy
  has_many :inappropriate_photos, :as => :photo_item, :dependent => :destroy

  def make_user_profile_photo(user_id)
    status = false
    if self.user_id == user_id
      profile = Profile.find_by_user_id(user_id) || Profile.new(:user_id => user_id)
      status = profile.update_avatar_from_url(self.image.url) ? "Updated" : "Error"
    else
      status = I18n.t('user.general_error')
    end
    return status
  end

#  def update_image_from_url(remote_avatar_url)
#    remote_avatar_url = remote_avatar_url.to_s.include?("http") ? remote_avatar_url : BASE_URL+remote_avatar_url
#    self.image = do_download_remote_image(remote_avatar_url)
#    return self.save
#  end
#
#  def do_download_remote_image(remote_avatar_url)
#    io = open(URI.parse(remote_avatar_url))
#    def io.original_filename; base_uri.path.split('/').last; end
#    io.original_filename.blank? ? nil : io
#  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
#  end

end
