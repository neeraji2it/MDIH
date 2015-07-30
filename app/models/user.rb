require 'digest/sha1'

class User < ActiveRecord::Base
  extend FriendlyId
  default_scope :conditions => ["deleted = false"]
  def self.find_deleted_by(conditions)
    with_exclusive_scope{find(:first, :conditions => [conditions])}
  end

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  friendly_id :login

  CHINESE_ZODIAC_SIGN = ["Rat", "Ox", "Tiger", "Rabbit", "Dragon", "Snake", "Horse", "Goat", "Monkey", "Rooster", "Dog", "Pig"]
  CHINESE_ZODIAC_SIGN2 = ["Dragon", "Snake", "Horse", "Goat", "Monkey", "Rooster", "Dog", "Pig","Rat", "Ox", "Tiger", "Rabbit"]
  RESERVED_LOGINS = ["new", "create", "edit", "activate", "forgot_password", "reset_password", "show", "edit", "update", "add_my_match", "my_matches", "delete_my_match", "hot_vote", "accept_invitation", "email_settings", "is_current_user?"]

  validates     :login, :gender, :orientation, :presence => true, :if => Proc.new { |user| user.facebook_id.nil? }
  validates_length_of       :login,    :within => 3..40, :if => Proc.new { |user| user.facebook_id.nil?}
  validates_uniqueness_of   :login, :if => Proc.new { |user| user.facebook_id.nil?}
  #  validates_format_of       :login,    :with => Authentication.login_regex, :message => "is invalid(#{Authentication.bad_login_message})", :if => Proc.new { |user| user.facebook_id.nil? }
  validates_format_of       :login,    :with => /\A\w+\z/, :message => I18n.t('model.valid_format_of.is_invalid'), :if => Proc.new { |user| user.facebook_id.nil? }

  #  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true


  validates     :email, :date_of_birth, :presence => true, :if => Proc.new { |user| user.facebook_id.nil? }
  #validates    :first_name,  :last_name, :presence => true, :if => Proc.new { |user| user.facebook_id.nil? }, :on => :update
  validates_length_of       :email, :within => 6..100 , :if => Proc.new { |user| user.facebook_id.nil?}#r@a.wk
  validates_uniqueness_of   :email, :if => Proc.new { |user| user.facebook_id.nil? }
  validates_format_of       :email, :with => Authentication.email_regex, :message => Authentication.bad_email_message, :if => Proc.new { |user| user.facebook_id.nil? }
  #validates_length_of       :first_name,  :last_name,     :maximum => 40, :if => Proc.new { |user| user.facebook_id.nil? }, :on => :update
  
  def validate
    if RESERVED_LOGINS.include?(self.login)
      self.errors.add(:login, I18n.t('model.validate.self.error2'))
    end
  end

  before_create :make_activation_code
  after_create  :send_emails

  has_one :profile, :dependent => :destroy
  has_many :friends_users, :dependent => :destroy
  has_many :friends_requests, :class_name => "FriendsUser", :foreign_key => :friend_id, :dependent => :destroy
  #  has_many :friend_of, :class_name => "FriendsUser", :foreign_key => :friend_id, :dependent => :destroy
  has_many :friends ,:class_name => "User", :through => :friends_users, :conditions => ["friends_users.status = 'accepted'"]
  has_many :requested_friends ,:class_name => "User", :through => :friends_requests, :conditions => ["friends_users.status = 'pending'"], :source => :user

  #  has_and_belongs_to_many :friends, :class_name => "User", :association_foreign_key => "friend_id", :join_table => "friends", :uniq => true,
  #    :delete_sql =>'DELETE FROM friends WHERE user_id = #{id} or friend_id = #{id}'
  has_many :imported_contacts, :order => 'email ASC', :dependent => :destroy
  has_and_belongs_to_many :profile_viewed, :class_name => "User",:foreign_key => "viewed_by", :association_foreign_key => "user_id", :join_table => "profile_viewers", :select => "users.*, profile_viewers.viewed_at", :order =>"viewed_at DESC", :uniq => true,
    :delete_sql =>'DELETE FROM profile_viewers WHERE user_id = #{id} or viewed_by = #{id}'
  has_and_belongs_to_many :profile_viewed_by, :class_name => "User", :association_foreign_key => "viewed_by", :join_table => "profile_viewers", :select => "users.*, profile_viewers.viewed_at", :order =>"viewed_at DESC", :uniq => true
  has_many :saved_searches, :dependent => :destroy
  #  has_many :quick_messages, :foreign_key => "to_id", :order => "sent_on DESC", :dependent => :destroy
  belongs_to :role
  has_many :in_messages, :foreign_key => "to_id", :class_name => "MessagesUser", :order => "created_at DESC", :dependent => :destroy
  #  has_many :out_messages, :foreign_key => "from_id", :class_name => "MessagesUser", :order => "created_at DESC", :group => "message_id", :dependent => :destroy
  has_many :messages, :dependent => :destroy
  #  has_many :received_messages, :through => :out_messages, :foreign_key => "message_id", :class_name => "Message", :order => "created_at DESC",  :source => :message
  #  has_many :sent_messages, :through => :in_messages, :foreign_key => "message_id", :class_name => "Message", :order => "created_at DESC",  :source => :message
  has_many :sent_messages, :class_name => "Message", :order => "created_at DESC", :conditions => ["message_type = 'sent'"], :dependent => :destroy
  has_many :draft_messages, :class_name => "Message", :order => "created_at DESC", :conditions => ["message_type = 'draft'"], :dependent => :destroy
  has_many :sent_gifts, :conditions => ["sender_status != 'deleted' and (sender_status != 'pending' and receiver_status != 'pending')"], :dependent => :destroy
  has_many :received_gifts, :foreign_key => :sent_to, :conditions => ["receiver_status != 'deleted' and (sender_status != 'pending' and receiver_status != 'pending')"], :class_name => "SentGift", :dependent => :destroy
  has_many :user_sent_gifts, :foreign_key => :user_id, :class_name => "SentGift", :dependent => :destroy
  has_many :user_received_gifts, :foreign_key => :sent_to, :class_name => "SentGift", :dependent => :destroy
  has_many :albums, :dependent => :destroy, :order => "created_at ASC"
  has_many :photos, :dependent => :destroy, :order => "created_at DESC"
  has_many :my_blocked_users, :class_name => "BlockedUser", :dependent => :destroy, :foreign_key => "user_id", :source => :blocked_user
  has_many :blocked_users , :through => :my_blocked_users, :class_name => "User"
  has_many :blocked_me, :class_name => "BlockedUser", :dependent => :destroy, :foreign_key => "blocked_user_id"
  has_many :who_blocked_me , :through => :blocked_me, :class_name => "User", :source => :user

  has_many :my_match_users , :class_name => "MyMatch", :dependent => :destroy, :foreign_key => "user_id", :source => :matcher#, :order => "created_at DESC"
  has_many :my_matches , :through => :my_match_users, :class_name => "User", :source => :matcher
  has_many :i_am_matched_to, :class_name => "MyMatch", :dependent => :destroy, :foreign_key => "matcher_id", :source => :user

  has_many :photo_comments, :dependent => :destroy

  has_many :hot_votes, :foreign_key => :user_id, :dependent => :destroy
  has_many :hot_voted, :class_name => "HotVote", :foreign_key => :hoter_id, :dependent => :destroy
  has_many :hot_votes_users ,:class_name => "User", :through => :hot_votes,  :source => :hoter
  has_many :hot_voted_users ,:class_name => "User", :through => :hot_voted,  :source => :user

  has_many :date_schedules, :foreign_key => "user_id",:dependent => :destroy
  has_many :requested_date_schedules, :class_name => "DateSchedule", :foreign_key => "dater_id",:dependent => :destroy
  has_many :date_schedule_users, :through => :date_schedules , :class_name => "User", :source => :dater
  has_many :requesed_date_schedule_users, :through => :requested_date_schedules, :class_name => "User", :source => :user
  has_many :date_schedule_replies, :dependent => :destroy
  has_many :message_templates, :dependent => :destroy, :order => "updated_at DESC"
  has_many :email_settings, :dependent => :destroy, :order => "created_at DESC"
  has_many :inappropriate_photos, :dependent => :destroy, :order => "created_at DESC"
  has_many :payments, :dependent => :destroy, :order => "created_at DESC"
  has_one  :user_location, :dependent => :destroy
  has_many :messages_replies, :dependent => :destroy
  has_many :messages_users, :dependent => :destroy, :foreign_key => "to_id"
  has_many :received_messages, :class_name => "Message", :foreign_key => :receiver_id, :dependent => :destroy
  has_many :sent_messages, :class_name => "Message", :foreign_key => :user_id, :dependent => :destroy
  # --------- chats --------------
  has_many :recieved_chats, :class_name => "Chat", :foreign_key => :reciever_id, :dependent => :destroy
  has_many :sent_chats, :class_name => "Chat", :foreign_key => :sender_id, :dependent => :destroy
  belongs_to :video_chat_user, :class_name => "User", :foreign_key => :video_chat_sender_id

  def intails_chats
    self.last_login ? [self.recieved_chats.since(self.last_login).read + self.sent_chats.since(self.last_login).read].flatten.sort{|a, b| a.created_at <=> b.created_at} : []
  end

  def chats(options={})
    #    [self.recieved_chats.since().read + self.sent_chats.since().read].flatten.sort{|a, b| b.created_at <=> a.created_at}
    #self.last_login ? [self.recieved_chats.since(self.last_login).read + self.sent_chats.since(self.last_login).read].flatten.sort{|a, b| a.created_at <=> b.created_at} : []
    [Chat.messages(options[:reciever_id], options[:sender_id]).read].flatten.sort{|a, b| b.created_at <=> a.created_at}
  end

  #  def index_chats
  #    self.last_login ? [self.recieved_chats.since(self.last_login).read + self.sent_chats.since(self.last_login).read].flatten.sort{|a, b| a.created_at <=> b.created_at} : []
  #  end
  # ------------------------------

  scope :datable_users, lambda{|user_id|
    {
      :joins => "left join user_email_counts count_one on count_one.sender_id = #{user_id}  and count_one.email_count >=2
                  left join user_email_counts count_two on count_two.receiver_id = #{user_id} and count_two.email_count >=2",
      :conditions => "count_one.receiver_id=count_two.sender_id and users.id = count_one.receiver_id",
      :order => "login ASC"
    }
  }
  scope :all_blocked_users, lambda{
    {
      :select => "users.*",
      :conditions => " users.id IN (SELECT distinct(users.id) FROM users, blocked_users
                      WHERE blocked_users.user_id = users.id)",
      :order => "login ASC"
    }
  }


  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :date_of_birth,
    :gender, :status, :role_id, :last_login_at, :activated_at, :facebook_id, :crypted_email, :zip, :fb_small_image, :fb_big_image,
    :is_online, :orientation, :dont_show_me_to_straight_users, :deleted, :deleted_at, :looking_for, :interested_in, :time_zone, :logged_in_from,:last_accessed_at, :last_login, :rest_time, :available_today, :rest_time_hours, :chat_status

  # indexing for sphinax search
  define_index do
    #    indexes first_name, :sortable => true
    #    indexes middle_name, :sortable => true
    #    indexes last_name, :sortable => true
    indexes email, :sortable => true
    indexes login, :sortable => true
    indexes orientation, :sortable => true
    has role_id
    where "status = true"
  end

  def name
    #    "#{self.first_name} #{self.middle_name} #{self.last_name}"
    display_name
  end

  def to_s
    self.name.present? ? self.name : self.login
  end

  def online_status
    if self.last_accessed_at and self.is_online and self.chat_status == true
      self.last_accessed_at < 5.minutes.ago ? "offline" : "online"
    else
      return "offline"
    end
  end

  def send_emails
    users = User.find(:all , :conditions => ["zip = '#{self.zip}' and email != '#{self.email}'"]) if !self.zip.to_s.blank?
    if !users.blank?
      if users.count >= 3
        users.each do |user|
          UserMailer.new_user_notification(self, user).deliver
        end
      end
    end
  end

  def json_data
    self.profile_image

    {
      :name => self.display_name.to_s,
      :id => self.id,
      :status => self.online_status,
      :login => self.login,
      :age => self.age,
      :gender => self.gender,
      :profile_image => (self.facebook_id.present? ? (self.profile ? (self.profile.avatar_file_name != "picture_type_large.jpg" ? self.profile.avatar.url(:original) : self.fb_big_image) : self.fb_big_image) : (self.profile ? self.profile.avatar.url(:original)  : "/assets/default_avatar.jpg"))
    }
  end

  def read_chats
    chats = self.recieved_chats.unread
    chats.each{|c| c.read_now}
    chats
  end
  
  def contacted_user_ids
    User.find_by_sql("select DISTINCT(messages.receiver_id) AS id from messages where id IN (select id from messages where user_id = #{self.id}) UNION select sent_to from sent_gifts where user_id = #{self.id}").map{|u| u.id}
  end

  def is_admin?
    self.role ? self.role.name == "admin" : false
  end

  def is_valid_account?
    !(self.email.nil? or self.gender.nil? or self.orientation.nil? )
  end

  def my_latest_match_user
    self.my_match_users.all(:order => "created_at DESC").first ? self.my_match_users.all(:order => "created_at DESC").first.matcher : nil
  end

  def all_blocked_user_ids
    return (my_blocked_users.map{|mbl| mbl.blocked_user_id} + blocked_me.map{|blm| blm.user_id})
  end

  def chinese_zodiac_sign
    sign = ""
    if self.date_of_birth
      year = (self.date_of_birth < ("02/05/#{self.date_of_birth.year}").to_date) ? (self.date_of_birth.year - 1) : self.date_of_birth.year
      sign = year<2000 ? CHINESE_ZODIAC_SIGN[(year.to_s[2..3].to_i)%12] : CHINESE_ZODIAC_SIGN2[(year.to_s[2..3].to_i)%12]
    end
    return sign
  end

  def cm_to_in(centemetrs)
    feets = (centemetrs / 30.48).floor
    inches_total  = (centemetrs/ 2.54)
    inches = inches_total - (feets * 12)
    puts "#{centemetrs} = #{feets} ft #{inches.to_i} inc"
  end

  def in_to_cm(inches)
    feets, inc = inches.to_s.split('.').first, inches.to_s.split('.').last
    cm = (feets.to_i * 30.48) + (inc.to_i * 2.54)
    puts cm
  end

  def add_location(params={})
    begin
      location_det = nil
      if params[:ip_address]
        location_det = MultiGeocoder.geocode(params[:ip_address])
        location_hash = {:ip_address => params[:ip_address], :lng => location_det.lng, :lat => location_det.lat, :city => location_det.city, :state => location_det.state}
      elsif !params[:lng].to_s.blank? and !params[:lat].to_s.blank?
        location_det = MultiGeocoder.reverse_geocode "#{params[:lat]}, #{params[:lng]}"
        location_hash = {:lng => params[:lng], :lat => params[:lat], :city => location_det.city, :state => location_det.state}
      end

      if !self.user_location.nil?
        self.user_location.update_attributes(location_hash) if location_det
      else
        UserLocation.new(location_hash.merge(:user_id => self.id)).save
      end
    rescue Exception => e
      logger.error ">>>>>>>>>>>>> Update user's location failed >>>>>>>>>>>"
      logger.error e
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password, store_login_history)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    if (u && u.authenticated?(password) && u.status)
      LoginHistory.create(:user_id => u.id, :logged_at => Time.now) if store_login_history
      return u
    else
      return nil
    end
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  # return user's firstname + middle_name + last_name as a string
  def full_name
    if self.login
      return self.login.capitalize
    end
    #    return self.first_name.to_s+" "+self.middle_name.to_s+" "+self.last_name.to_s
  end

  def display_name
    return self.facebook_id.nil? ? (!self.login.to_s.blank? ? self.login.capitalize : self.full_name) : self.full_name
  end

  def age
    uage = ""
    if self.date_of_birth
      #      (Date.today - self.date_of_birth).to_i/364
      now = Time.now.utc.to_date
      uage = now.year - self.date_of_birth.year - ((now.month > self.date_of_birth.month || (now.month == self.date_of_birth.month && now.day >= self.date_of_birth.day)) ? 0 : 1)
    end
    return uage
  end

  def humanized_gender
    self.gender == "Male" ? "Man" : (self.gender == "Female" ? "Women" : self.gender)
  end

  def age_gender_info
    info = ""
    if self.orientation.to_s.blank?
      info = age.to_s+" year old "+humanized_gender
    elsif self.orientation.to_s == 'Bisexual'
      info = age.to_s+" year old "+self.orientation.to_s+" "+self.gender.to_s
    elsif self.orientation.to_s == 'Gay'
      info = age.to_s+" year old "+humanized_gender+", Orientation "+self.orientation
    end
  end

  # To make activation code to send in activation email
  def make_activation_code
    self.crypted_email = Digest::SHA1.hexdigest(self.email) if self.facebook_id.nil?
    self.status = self.status.nil? ? false : self.status
    if self.status
      self.activation_code = nil
      self.activated_at = Time.now
    else
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      self.activated_at = nil
    end
    self.role_id = self.role_id.nil? ? 2 : self.role_id
  end

  # To delete activation code after user activated
  def delete_activation_code
    self.status = true
    self.activation_code = ""
    self.activated_at = Time.now
    self.credits = SIGNUP_CREDITS if self.credits.to_i == 0
    save(:validate => false)
  end

  # To delete reset code after reset the user's password
  def delete_reset_code
    self.password_reset_code = nil
    save(:validate => false)
  end

  # Will create reset code to a user
  def create_reset_code
    @reset = true
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(:validate => false)
  end

  def self.recent_notifications(current_user, limit=nil)
    limit_text = limit.nil? ? "" : "LIMIT #{limit}"
    #    schedules = User.find_by_sql("SELECT date_schedules.id, users.id AS user_id, users.login, concat(users.first_name, ' ', users.last_name) AS user_name,
    #                      concat(users.first_name, ' ', users.last_name, ' has sent date request') AS message, date_schedules.updated_at AS date_on
    #                      FROM `date_schedules`
    #                      LEFT JOIN users on users.id = date_schedules.user_id
    #                      WHERE ((dater_status != 'deleted' and dater_status != 'accepted' )) AND (`date_schedules`.dater_id = #{user_id})
    #                      ORDER BY date_on DESC #{limit_text}
    #")
    notifications = []
    #    for schedule in schedules
    #      notification = Notification.new
    #      notification.assign_values(schedule.id, schedule.user_id, schedule.login, schedule.user_name, schedule.message, schedule.date_on, 'date_schedule')
    #      notifications << notification
    #    end
    #    reschedules = User.find_by_sql("SELECT date_schedules.id, users.id AS user_id, users.login, concat(users.first_name, ' ', users.last_name) AS user_name,
    #                      concat(users.first_name, ' ', users.last_name, ' has changed your date schedule') AS message, date_schedules.updated_at AS date_on
    #                      FROM `date_schedules`
    #                      LEFT JOIN date_schedule_replies on date_schedule_replies.date_schedule_id = date_schedules.id
    #                      LEFT JOIN users on users.id = date_schedule_replies.user_id
    #                      WHERE ((dater_status != 'deleted' and dater_status != 'accepted' ) AND
    #                      ((`date_schedules`.user_id = #{user_id} AND date_schedule_replies.user_id = date_schedules.dater_id)) AND date_schedules.id  = date_schedule_replies.date_schedule_id)
    #                      ORDER BY date_schedule_replies.created_at DESC #{limit_text}
    #")
    #    for reschedule in reschedules
    #      notification = Notification.new
    #      notification.assign_values(reschedule.id, reschedule.user_id, reschedule.login, reschedule.user_name, reschedule.message, reschedule.date_on, 'date_schedule')
    #      notifications << notification
    #    end
    #
    #    deleted_schedules =User.find_by_sql("SELECT date_schedules.id, users.id AS user_id, users.login, concat(users.first_name, ' ', users.last_name) AS user_name,
    #                      concat(users.first_name, ' ', users.last_name, ' has deleted date request') AS message, date_schedules.updated_at AS date_on
    #                      FROM `date_schedules`
    #                      LEFT JOIN users on users.id = date_schedules.user_id or users.id = date_schedules.dater_id and (users.id != #{user_id})
    #                      WHERE (dater_id = #{user_id} AND user_status IN ('deleted', 'accepted_deleted')) OR (user_id = #{user_id} AND dater_status IN ('deleted', 'accepted_deleted')) AND (users.id != #{user_id})
    #                      ORDER BY date_on DESC #{limit_text}#")
    #    for deleted_schedule in deleted_schedules
    #      notification = Notification.new
    #      notification.assign_values(deleted_schedule.id, deleted_schedule.user_id, deleted_schedule.login, deleted_schedule.user_name, deleted_schedule.message, deleted_schedule.date_on, 'date_schedule')
    #      notifications << notification
    #    end

    messages = (limit.to_s.blank? ? current_user.received_messages.where("messages.receiver_status = 'unread'").all : current_user.where("messages.receiver_status = 'unread'").received_messages.all(:limit => limit))
    for message in messages
      if (message.user_id == current_user.id and message_latest_reply = message.latest_reply(current_user.id))
        user = message_latest_reply.user
        time_on = message_latest_reply.created_at
      else
        time_on = message.created_at
        user = message.user
      end
      notification = Notification.new
      notification.assign_values(message.id, user.id, user.login, user.full_name, user.is_online, user.last_accessed_at, user.gender, user.available_today,user.chat_status, message.body, time_on.strftime("%Y-%m-%d %H:%M:%S"), 'message')
      notifications << notification
    end
    hot_votes = User.find_by_sql("SELECT hot_votes.id, users.id AS user_id, users.login, users.login AS user_name, users.last_accessed_at AS last_accessed_at,users.gender AS user_gender,
                                  concat(users.login, ' has voted you as hot') AS message, hot_votes.created_at AS date_on, users.is_online AS is_online, users.available_today AS available_today, users.chat_status AS chat_status
                                  FROM hot_votes
                                  LEFT JOIN users on users.id = hot_votes.user_id
                                  WHERE hot_votes.hoter_id = #{current_user.id}
                                  ORDER BY date_on DESC #{limit_text}
      ")
    for hot_vote in hot_votes
      notification = Notification.new
      notification.assign_values(hot_vote.id, hot_vote.user_id, hot_vote.login, hot_vote.user_name , hot_vote.is_online, hot_vote.last_accessed_at, hot_vote.user_gender, hot_vote.available_today, hot_vote.chat_status, hot_vote.message, hot_vote.date_on, 'hot_vote')
      notifications << notification
    end
    photo_comments = User.find_by_sql("SELECT photos.id, users.id AS user_id, users.login,users.login AS user_name, users.is_online AS is_online, users.available_today AS available_today, users.chat_status AS chat_status,users.last_accessed_at AS last_accessed_at, users.gender AS user_gender,
                                      concat(users.login, ' has commented on your photo') AS message, photo_comments.created_at AS date_on, photos.album_id AS parent_id
                                      FROM photo_comments
                                      LEFT JOIN photos on photos.id = photo_comments.photo_id
                                      LEFT JOIN users on users.id = photo_comments.user_id
                                      WHERE photos.user_id = #{current_user.id} AND photo_comments.user_id != #{current_user.id}
                                      ORDER BY date_on DESC #{limit_text}
      ")
    for photo_comment in photo_comments
      notification = Notification.new
      notification.assign_values(photo_comment.id, photo_comment.user_id, photo_comment.login, photo_comment.user_name , photo_comment.is_online, photo_comment.last_accessed_at, photo_comment.user_gender, photo_comment.available_today,photo_comment.chat_status, photo_comment.message, photo_comment.date_on, 'photo_comment', photo_comment.parent_id)
      notifications << notification
    end

    received_gifts = User.find_by_sql("SELECT sent_gifts.id, users.id AS user_id, users.login, users.login AS user_name, users.is_online AS is_online, users.available_today AS available_today, users.chat_status AS chat_status,users.last_accessed_at AS last_accessed_at, users.gender AS user_gender,
                            concat(users.login, ' has sent you a gift') AS message, sent_gifts.sent_on  AS date_on FROM sent_gifts
                            left join users on users.id = sent_gifts.user_id
                            where sent_gifts.sent_to = #{current_user.id}
                            order by sent_gifts.sent_on DESC #{limit_text}
      ")
    for received_gift in received_gifts
      notification = Notification.new
      notification.assign_values(received_gift.id, received_gift.user_id, received_gift.login, received_gift.user_name, received_gift.is_online, received_gift.last_accessed_at, received_gift.user_gender, received_gift.available_today,received_gift.chat_status, received_gift.message, received_gift.date_on, 'gift', nil)
      notifications << notification
    end
    if limit.to_s.blank?
      return notifications.sort{|a,b| b.time_on.to_datetime <=> a.time_on.to_datetime}
    else
      return notifications.sort{|a,b| b.time_on.to_datetime <=> a.time_on.to_datetime} [0...limit]
    end
    
  end

  def is_online?
    return self.online_status == 'online'
  end

  def basic_profile_info
    prof = Profile.find(:first, :select => "id, avatar_file_name, city, avatar_content_type, avatar_file_size, state, country, headline, avatar_updated_at", :conditions => ["user_id = #{self.id}"]) || Profile.new #self.profile
    self['profile_avatar'] = prof.avatar.url
    self['profile_avatar_default'] = prof.avatar.url(:default)
    self['profile_avatar_tumbnail'] = prof.avatar.url(:other)

    self['profile_city'] = prof.city
    self['profile_state'] = prof.state
    self['profile_country'] = prof.country
    self['profile_headline'] = prof.headline

    self['photos_count'] = self.photos.count
    self['online_status'] = online_status
    self['age'] = self.age.to_s
    self['display_name'] = self.display_name
  end

  def profile_image
    prof = Profile.find(:first, :select => "id, avatar_file_name, avatar_content_type, avatar_file_size, avatar_updated_at", :conditions => ["user_id = #{self.id}"]) || Profile.new #self.profile
    self['profile_avatar'] = prof.avatar.url
    self['profile_avatar_default'] = prof.avatar.url(:default)
    self['profile_avatar_tumbnail'] = prof.avatar.url(:other)
    self['display_name'] = self.display_name
  end

  def recreate_activation_code
    self.status = false
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    self.activated_at = nil
    return (self.save(:validate => false) and UserMailer.signup_notification(self).deliver)
  end

  def is_online_on_web?
    return (is_online? and logged_in_from.to_s == 'web')
  end

  def is_online_on_iphone?
    return (is_online? and logged_in_from.to_s == 'iphone')
  end

  def user_time_zone
    return !self.time_zone.to_s.blank? ? self.time_zone.to_s : 'Pacific Time (US & Canada)'
  end

  def zip_code_city
    zip_code_city = ZipCode.find(:first, :conditions => ["zip = '#{self.zip}'"]) if !self.zip.to_s.blank?
    return (zip_code_city ? zip_code_city.city : "")
  end

  def profile_address
    if u_profile = self.profile
      profile_city = [zip_code_city.to_s.downcase, self.profile.city.to_s.downcase].uniq
      profile_city = (profile_city.length == 1 ? [(self.profile.city.to_s || zip_code_city.to_s)] : [zip_code_city.to_s, self.profile.city.to_s])
      return (profile_city+[profile.state, profile.country]).delete_if{|a| a.to_s.blank?}.join(", ")
    else
      return zip_code_city.to_s
    end
  end

  def available_today_expire
    if !self.rest_time.blank?
      if self.rest_time <= Time.now # ended already
        self.update_attribute(:available_today,false)
      end
    end
  end


end


class Notification < ActiveRecord::Base
  def self.columns
    @columns ||= [];
  end

  def assign_values(id, user_id, login, user_name,is_online,last_accessed_at,gender, available_today, chat_status, message, time_on, notification_type, parent_id=nil)
    self['id'] = id
    self['user_id'] = user_id
    self['login'] = login
    self['user_name'] = user_name
    self['is_online'] = is_online
    self['last_accessed_at'] = last_accessed_at
    self['gender'] = gender
    self['available_today'] = available_today
    self['chat_status'] = chat_status
    self['message'] = message
    #    self['time_on'] = time_on
    self['notification_type'] = notification_type
    self['parent_id'] = parent_id
    n_user = User.find(:first, :conditions => ["id = #{user_id}"])
    if n_user
      n_user.profile_image
      self['profile_avatar'] = n_user.profile_avatar
      self['profile_avatar_default'] = n_user.profile_avatar_default
      self['profile_avatar_tumbnail'] = n_user.profile_avatar_tumbnail
      self['display_name'] = n_user.display_name
      self['time_on'] = time_on.to_time.in_time_zone(n_user.user_time_zone)
      self['age'] = n_user.age.to_s
      self["online_status"] = n_user.online_status
    else
      self['profile_avatar'] = ""
      self['profile_avatar_default'] = ""
      self['profile_avatar_tumbnail'] = ""
      self['display_name'] = ""
      self['time_on'] = time_on
      self['age'] = ""
      self["online_status"] = ""
    end
  end


end
