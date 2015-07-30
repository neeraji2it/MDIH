class DraftMessagesUser < ActiveRecord::Base
  belongs_to :message
  belongs_to :user, :foreign_key => "to_id"
end
