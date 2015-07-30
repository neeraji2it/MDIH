class DateScheduleReply < ActiveRecord::Base

  validates :reason, :presence => true
  validates :proposed_date_on, :presence => {:message => I18n.t('model.valid_presence_of.select_time_for_schedule'), :if => :is_required?}
  validates  :place, :presence =>  {:message => I18n.t('model.valid_presence_of.place_cant_blank'), :if => :is_required?}
  validate :validate_proposed_date_on
  
  def validate_proposed_date_on
    self.client_current_time = self.client_current_time ? (self.client_current_time+(15*60)).to_time : Time.now+(15*60)
    if !self.proposed_date_on.to_s.blank? and self.proposed_date_on.to_time.strftime("%m/%d/%Y %H:%M").to_time <= client_current_time #Time.now.tomorrow
      self.errors.add(:proposed_date_on, I18n.t('model.validate.self.error'))
    end
  end


  belongs_to :date_schedules
  belongs_to :user

  attr_accessor :schedule_status, :client_current_time #, :reason, :proposed_date_on, :place, :user_id
  #  attr_accessible :schedule_status , :reason, :proposed_date_on, :place, :user_id

  def is_required?
    return self.schedule_status == 'reschedule' ? true : false
  end

end
