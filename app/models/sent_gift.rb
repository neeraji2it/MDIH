class SentGift < ActiveRecord::Base
  belongs_to :user
  belongs_to :receiver, :foreign_key => :sent_to, :class_name => "User"
  belongs_to :product
end
