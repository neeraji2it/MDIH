class MessageTemplate < ActiveRecord::Base
 validates :subject, :body, :presence => true

  belongs_to :user
end
