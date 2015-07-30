class UserLocation < ActiveRecord::Base
  belongs_to :user
  acts_as_mappable

  def self.get_nearby_locations(lat, lng)
    return  UserLocation.within(10, :origin => [lat, lng])
  end
end
