class Album < ActiveRecord::Base

  validates :name, :presence => true
  validates :name, :length => {:in => 3..40}
  
  belongs_to :user
  has_many :photos, :dependent => :destroy, :order => "created_at DESC"

  def cover_photo
    if self.cover_photo_id and Photo.exists?(:id => self.cover_photo_id)
      Photo.find(self.cover_photo_id)
    else
      self.photos.first
    end
  end
  
end
