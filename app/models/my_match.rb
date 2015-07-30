class MyMatch < ActiveRecord::Base
  belongs_to :user, :foreign_key => :user_id
  belongs_to :matcher, :foreign_key => :matcher_id, :class_name => "User"
end
