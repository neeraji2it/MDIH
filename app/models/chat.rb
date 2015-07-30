class Chat < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :reciever, :class_name => "User"

  validates :sender_id, :reciever_id, :text, :presence => true

  scope :unread, :conditions => {:read_at => nil}
  scope :read, :conditions => "chats.read_at IS NOT NULL"
  scope :since, lambda{|date_time| {:conditions => ["created_at >= ?", date_time.to_time.in_time_zone.to_s(:db)]} }
  scope :from_sender_ids, lambda{|user_ids| {:conditions => {:sender_id => user_ids}} }
  scope :to_reciever_ids, lambda{|user_ids| {:conditions => {:reciever_id => user_ids}} }
  scope :exclude_sender_ids, lambda{|user_ids| {:conditions => ["sender_id NOT IN (?)", user_ids << 0] } }
  scope :exclude_reciever_ids, lambda{|user_ids| {:conditions => ["reciever_id NOT IN (?)", user_ids << 0] } }

  scope :messages, lambda {|reciever_id, sender_id|
    {
      :conditions  => ["reciever_id IN (#{reciever_id},#{sender_id}) AND sender_id IN (#{reciever_id},#{sender_id})"]
    }
  }

  def read_now
    self.update_attributes(:read_at => Time.now)
  end

  def is_read?
    self.read_at.present?
  end

  def is_unread?
    !self.is_read?
  end

  def json_data
    {
      :id => self.id,
      :text => self.text,
      :senderId => self.sender_id,
      :recieverId => self.reciever_id,
      :senderName => self.sender.try(:display_name),
      :recieverName => self.reciever.try(:display_name),
      :senderAge => self.sender.try(:age),
      :recieverAge => self.reciever.try(:age),
      :senderPhoto => (self.sender.facebook_id.present? ? (self.sender.profile ? (self.sender.profile.avatar_file_name != "picture_type_large.jpg" ? self.sender.profile.avatar.url(:original) : self.sender.fb_big_image) : self.sender.fb_big_image) : (self.sender.profile ? self.sender.profile.avatar.url(:original)  : "/assets/default_avatar.jpg")),
      :recieverPhoto => (self.reciever.facebook_id.present? ? (self.reciever.profile ? (self.reciever.profile.avatar_file_name != "picture_type_large.jpg" ? self.reciever.profile.avatar.url(:original) : self.reciever.fb_big_image) : self.reciever.fb_big_image) : (self.reciever.profile ? self.reciever.profile.avatar.url(:original)  : "/assets/default_avatar.jpg")),
      :senderGender => self.sender.gender,
      :recieverGender => self.reciever.gender,
      :senderStatus => self.sender.try(:online_status),
      :recieverStatus => self.reciever.try(:online_status),
      :time => self.created_at.strftime("%d-%m-%Y %H:%M:%S")
    }
  end
end
