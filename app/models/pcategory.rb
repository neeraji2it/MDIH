class Pcategory < ActiveRecord::Base
  
  validates :name, :presence => true
  validates_length_of :name, :within => 3..25
  validates_uniqueness_of :name

  has_many :pcategories_products, :dependent => :destroy
  has_many :products, :through => :pcategories_products
  
end
