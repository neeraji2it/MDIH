class PcategoriesProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :pcategory
end
