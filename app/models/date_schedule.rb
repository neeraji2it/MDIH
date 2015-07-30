class DateSchedule < ActiveRecord::Base

  attr_accessor :client_current_time

  validates :dater_id, :presence => {:message => I18n.t('model.valid_presence_of.select_user_to_date')}
  validates :proposed_date_on, :presence => { :message => I18n.t('model.valid_presence_of.select_time_for_schedule')}
  validates :proposed_place, :presence => {:message => I18n.t('model.valid_presence_of.place_cant_blank')}
  validate :validate_proposed_date_on
  
  belongs_to :user, :foreign_key => :user_id
  belongs_to :dater, :class_name => "User", :foreign_key => :dater_id
  has_many :date_schedule_replies, :dependent => :destroy

  before_create :change_schedule_date_to_utc

  scope :proposed_dates, lambda{|user_id|
    {
      :conditions => ["(dater_id = #{user_id} AND dater_status = 'pending')AND (date_on > '#{Time.now.strftime('%Y-%m-%d').to_s}')"],
      :order => "date_on DESC"
    }
  }
  def validate_proposed_date_on
    self.client_current_time = self.client_current_time ? (self.client_current_time+(15*60)).to_time : Time.now+(15*60)
    self.date_on = self.proposed_date_on
    self.place = self.proposed_place
    if !self.proposed_date_on.to_s.blank? and (self.proposed_date_on.to_time.strftime("%m/%d/%Y %H:%M").to_time) <= client_current_time #Time.now.tomorrow
      self.errors.add(:proposed_date_on, I18n.t('model.validate.self.error'))
    end
    if self.user_id and !User.find(self.user_id).friends.all(:select => "users.id").map{|user| user.id}.include?(self.dater_id) #!User.datable_users(self.user_id).all(:select => "users.id").map{|user| user.id}.include?(self.dater_id)
      self.errors.add(:dater_id, I18n.t('model.validate.self.error1'))
    end
  end

  def self.accepted_dates(user_id)
    return DateSchedule.count(:conditions => ["(user_id = ? OR dater_id = ?) AND (user_status = 'accepted' AND dater_status = 'accepted') AND (date_on > '#{Time.now.strftime('%Y-%m-%d').to_s}')", user_id,user_id])
  end

  def self.upcoming_date(user_id)
    return DateSchedule.first(:conditions => ["(user_id = ? OR dater_id = ?) AND (user_status = 'accepted' AND dater_status = 'accepted') AND (date_on > '#{Time.now.strftime('%Y-%m-%d').to_s}')", user_id,user_id], :order => "date_on ASC")
  end

  def change_schedule_date_to_utc
    self.date_on = self.proposed_date_on = DateTime.strptime(self.proposed_date_on.strftime("%Y-%m-%d %I:%M:%S ")+ActiveSupport::TimeZone[user.user_time_zone].to_s.split(" ").first.to_s.gsub(/\(GMT|\:|\)/, ""), "%Y-%m-%d %H:%M:%S %Z").utc
  end


end
