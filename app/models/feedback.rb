class Feedback < ActiveRecord::Base
  validates :subject,  :email, :comment, :presence => true
  validates_format_of   :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
end
