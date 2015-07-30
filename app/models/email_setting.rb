class EmailSetting < ActiveRecord::Base
  belongs_to :user
  attr_accessor :time, :available
end
