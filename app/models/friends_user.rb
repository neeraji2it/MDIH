class FriendsUser < ActiveRecord::Base

  belongs_to :user, :foreign_key => :user_id
  belongs_to :friend, :foreign_key => :friend_id, :class_name => "User"
end
