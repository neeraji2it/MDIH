class Message < ActiveRecord::Base

  validates  :body, :presence => true
  belongs_to :user, :class_name => "User"
  belongs_to :receiver, :class_name => "User"
  #  has_many :messages_users, :dependent => :destroy
  #  has_many :receivers, :through => :messages_users, :class_name => "User", :foreign_key => "to_id"
  belongs_to :user
  #  has_many :draft_messages_users, :dependent => :destroy
  #  has_many :draft_message_receivers, :through => :draft_messages, :class_name => "User", :foreign_key => "to_id"
  #  has_many :replies, :class_name => "MessagesReply", :order => "created_at DESC", :dependent => :destroy

  has_many :api_message_replies, :through => :replies, :source => :user, :class_name => "User", :foreign_key => "user_id", :select => "users.id, users.login, users.facebook_id, messages_replies.body, messages_replies.created_at"
  #  has_many :message_receivers, :through => :messages_users, :source => :receiver, :class_name => "User", :foreign_key => "to_id", :select => "users.id, users.first_name, users.last_name, users.middle_name, users.login, users.facebook_id"
  #
  #  scope :sent_messages, lambda{|user_id|
  #    {
  #      :select => "DISTINCT messages.*",
  #      :joins => "LEFT JOIN messages_replies replies ON replies.message_id=messages.id ",
  #      :conditions => "(messages.user_id = #{user_id} or replies.user_id=#{user_id}) and messages.user_status != 'deleted' and messages.message_type = 'sent'",
  #      :order => "messages.updated_at DESC"
  #    }
  #  }

  #  scope :received_messages, lambda{|user_id|
  #    {
  #      #      :select => "DISTINCT messages.*",
  #      #      :joins => "LEFT JOIN messages_users mu ON mu.message_id = messages.id and mu.to_id = #{user_id} and mu.to_status != 'deleted' LEFT JOIN messages_replies replies ON replies.message_id=messages.id and messages.user_id = #{user_id}",
  #      #      :conditions => "(messages.user_status != 'deleted' and messages.user_status != 'sent')"
  #      :select => "DISTINCT messages.*",
  #      :joins => "LEFT JOIN messages_users mu ON mu.message_id = messages.id ",
  #      :conditions => "(mu.to_id = #{user_id} and mu.to_status != 'deleted') or (messages.user_id = #{user_id} and messages.user_status != 'deleted' and messages.has_replies = true)",
  #      :order => "messages.updated_at DESC"
  #    }
  #  }

  #  scope :unread_message_count, lambda{|user_id|
  #    {
  #      :select => "DISTINCT(messages.id)",
  #      :joins => "LEFT JOIN messages_users mu ON mu.to_id = #{user_id}",
  #      :conditions => "((mu.message_id = messages.id and mu.to_status = 'unread') or (messages.user_id = #{user_id} and messages.user_status = 'unread'))"
  #    }
  #  }
  #
  #  scope :unread_messages, lambda{|user_id|
  #    {
  #      :select => "DISTINCT messages.*",
  #      :joins => "LEFT JOIN messages_users mu ON mu.to_id = #{user_id}",
  #      :conditions => "((mu.message_id = messages.id and mu.to_status = 'unread') or (messages.user_id = #{user_id} and messages.user_status = 'unread'))",
  #      :order => "messages.updated_at DESC"
  #    }
  #  }

  def self.unread_count(user_id)
    return self.unread_message_count(user_id).all(:select => "DISTINCT(messages.id)").count
  end

  def to_address(current_user, to_ids=[])
    to_ids = to_ids.split(',').to_a#-current_user.who_blocked_me.all(:select => "users.id").map{|u| u.id}
    to_ids.each do |to|
      if self.message_type == 'sent'
        self.messages_users.build(:to_id => to, :to_status => 'unread')
      else
        self.draft_messages_users.build(:to_id => to)
      end
    end
  end

  def my_message_user(user_id)
    self.messages_users.first(:conditions => ["messages_users.to_id = #{user_id}"])
  end

  def latest_reply(user_id)
    self.replies.all(:conditions => ["user_id != ?", user_id], :limit => 1, :order => "created_at DESC").first
  end

  def my_latest_reply(user_id)
    self.replies.all(:conditions => ["user_id = ?", user_id], :limit => 1, :order => "created_at DESC").first
  end

  def make_deleted(user_id)
    if self.user_id == user_id
      self.update_attribute(:user_status, "deleted")
    end
    if self.receiver_id == user_id
      self.update_attribute(:receiver_status, "deleted")
    end
    if self.user_status == 'deleted' and self.receiver_status == 'deleted'
      self.destroy
    end
    #    if self.my_message_user(user_id)
    #      self.my_message_user(user_id).update_attributes(:to_status => "deleted")
    #    end
    #    if self.user_status == 'deleted' and !self.messages_users.map{|mu| mu.to_status == 'deleted' }.include?(false)
    #      self.destroy
    #    end
  end

  def sender_details(s_id, user_type)
    msender = User.find(:first, :conditions => ["id = ?", s_id], :select => "id, facebook_id, login")
    self["#{user_type}_id"] = msender.id
    self["#{user_type}_name"] = msender.display_name
    self["#{user_type}_profile_avatar"] = msender.profile_image
  end

  def receiver_details(id)
    User.find(id, :select => "id, login,is_online")
  end

  def message_sender(u_id)
    return message_sender_id(u_id) ? User.find(message_sender_id(u_id)) : nil
  end

  def message_sender_id(u_id)
    l_reply = latest_reply(u_id)
    return l_reply ? l_reply.user_id : self.user_id
  end

  def message_sent_on(u_id)
    l_reply = latest_reply(u_id)
    return l_reply ? l_reply.created_at : created_at
  end

  def message_receiver(u_id)
    return message_receiver_id(u_id) ? User.find_by_id(message_receiver_id(u_id)) : nil
  end

  def message_receiver_id(u_id)
    return (self.user_id == u_id ? ((message_user = messages_users.all(:limit => 1).first) ? message_user.to_id : nil) : self.user_id)
  end

  def message_received_on(u_id)
    l_reply = my_latest_reply(u_id)
    return l_reply ? l_reply.created_at : created_at
  end

  def get_replies_receivers_details(current_user)
    self[:message_receivers] = []
    self[:message_replies] = []
    for receiver in self.receivers.all(:select => "users.id, users.login, users.facebook_id")
      receiver.profile_image
      message_receiver = {:id => receiver.id, :login => receiver.login, :display_name => receiver.display_name,
        :profile_avatar => receiver['profile_avatar'], :profile_avatar_default => receiver['profile_avatar_default'], :profile_avatar_tumbnail => receiver['profile_avatar_tumbnail']}
      self[:message_receivers] << message_receiver
    end

    for message_reply in api_message_replies
      message_reply.profile_image
      reply = {:id => message_reply.id, :login => message_reply.login, :display_name => message_reply.display_name,
        :profile_avatar => message_reply['profile_avatar'], :profile_avatar_default => message_reply['profile_avatar_default'], :profile_avatar_tumbnail => message_reply['profile_avatar_tumbnail'],
        :body => message_reply.body, :created => message_reply.created_at.in_time_zone(current_user.user_time_zone)
      }
      self[:message_replies] << reply
    end

  end


  #  def json_data
  #    self.attributes
  #  end

  #  def to_json
  #    self.json_data.to_json
  #  end
end
