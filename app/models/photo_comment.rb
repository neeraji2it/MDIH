class PhotoComment < ActiveRecord::Base
  belongs_to :photo
  belongs_to :user

  validates :comment, :presence => true
  validates_length_of :comment, :within => 3..254

  def get_commenter
    self['user_name'] = self.user.display_name
  end
end
