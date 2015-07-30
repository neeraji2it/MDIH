class HotVote < ActiveRecord::Base

  belongs_to :user, :foreign_key => :user_id
  belongs_to :hoter, :foreign_key => :hoter_id, :class_name => "User"
  
end
