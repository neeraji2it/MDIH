class MessagesReply < ActiveRecord::Base

  validates  :body, :presence => true
  after_create :save_email_count

  belongs_to :user
  belongs_to :message

  def save_email_count
    if self.message.user_id == self.user_id
      self.message.messages_users.each do |message_user|
        user_email_count = UserEmailCount.find(:first, :conditions => ["sender_id = ? and receiver_id = ?", self.message.user_id, message_user.to_id])
        if user_email_count
          user_email_count.update_attributes(:email_count => user_email_count.email_count.to_i+1)
        else
          UserEmailCount.create(:sender_id => self.message.user_id, :receiver_id => message_user.to_id)
        end
      end
    else
      user_email_count = UserEmailCount.find(:first, :conditions => ["sender_id = ? and receiver_id = ?", self.user_id, self.message.user_id])
      if user_email_count
        user_email_count.update_attributes(:email_count => user_email_count.email_count.to_i+1)
      else
        UserEmailCount.create(:sender_id => self.user_id, :receiver_id => self.message.user_id)
      end
    end
  end

end
