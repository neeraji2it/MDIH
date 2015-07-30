class Invitation < ActiveRecord::Base

  belongs_to :user
  belongs_to :invited_user, :foreign_key => 'invited_id', :class_name => "User"
end
