class QuickMessage < ActiveRecord::Base

  validates :message, :presence => true

  belongs_to :sender, :class_name => "User", :foreign_key => "from_id"
  belongs_to :receiver, :class_name => "User", :foreign_key => "to_id"
end
