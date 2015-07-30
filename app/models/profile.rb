require 'country_select'
require 'open-uri'

class Profile < ActiveRecord::Base

  belongs_to :user
  has_many :photo_comments
  has_many :inappropriate_photos, :as => :photo_item, :dependent => :destroy
  attr_accessor :zip
#  has_attached_file :avatar,
#    :default_url => '/images/default_avatar.jpg',
#    :whiny => false,
#    :url =>  "/uploaded_files/profile/:id/:style/:basename.:extension",
#    :path=> ":rails_root/public/uploaded_files/profile/:id/:style/:basename.:extension",
#    :styles => {
#    :original => "900x900>",
#    :default => "280x190>",
#    :other => "96x96>" }

  has_attached_file :avatar, :styles => {:original => "900x900>",:default => "280x190>",:other => "96x96>" }

  validates_attachment_presence :avatar, :message => "is required"
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp', 'image/x-png', 'image/pjpeg']
	# Validation of the size of the attached file
  validates_attachment_size(:avatar, :less_than => 25.megabytes)

  # indexing for sphinax search
  define_index do
    has user_id
    
    indexes height
    indexes body_type
    indexes languages_spoken
    indexes marital_status
    indexes religion
    indexes smoke
    indexes drink
    indexes drugs

    indexes education_level
    indexes profession
    indexes income_level

    #    indexes looking_for , :sortable => true
    #    indexes user,  :sortable => true
  end

  def update_avatar_from_url(remote_image_url)
    remote_image_url = remote_image_url.to_s.include?("http") ? remote_image_url : BASE_URL+remote_image_url
    self.avatar = do_download_remote_image(remote_image_url)
    return self.save
  end

  def do_download_remote_image(remote_image_url)
    io = open(URI.parse(remote_image_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end


end
