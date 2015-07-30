class InappropriatePhoto < ActiveRecord::Base
  #  belongs_to :photo
  belongs_to :user
  belongs_to :photo_item, :polymorphic => true

  def photo_url
    if self.photo_item_type == "Photo"
      return self.photo_item.image.url(:original)
    elsif self.photo_item_type == "Profile"
      photo = Profile.find(:first, :conditions => ["id = ?", self.photo_item_id], :select => "id, avatar_file_name, avatar_content_type, avatar_file_size") || Profile.new
      return photo.avatar.url
    end
  end

  def reports_count
    return InappropriatePhoto.count(:conditions => ["photo_item_id = ? AND photo_item_type = ?", self.photo_item_id, self.photo_item_type])
  end
end
