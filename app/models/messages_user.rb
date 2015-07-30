class MessagesUser < ActiveRecord::Base
  validates :to_id, :presence => true
  validates :to_id,:numericality => true

  after_create :save_email_count

  belongs_to :receiver, :class_name => "User", :foreign_key => "to_id"
  belongs_to :message

  def save_email_count
    if self.message.message_type == 'sent'
      if user_email_count = UserEmailCount.find(:first, :conditions => ["sender_id = ? and receiver_id = ?",  self.message.user_id, self.to_id])
        user_email_count.update_attributes(:email_count => user_email_count.email_count.to_i+1)
      else
        UserEmailCount.create(:sender_id =>  self.message.user_id, :receiver_id => self.to_id)
      end
    end
  end

end
