class Product < ActiveRecord::Base

  validates :name, :credits, :presence => true
  validates_length_of :name, :within => 3..40
  validates_numericality_of :credits

#  has_attached_file :photo,
#    :default_url => '/images/default_avatar.jpg',
#    :url =>  "/uploaded_files/product/:id/:style/:basename.:extension",
#    :path=> ":Rails.root/public/uploaded_files/product/:id/:style/:basename.:extension",
#    :styles => {
#    :original => "500x500>",
#    :default => "120x120>" }

  has_attached_file :photo, :styles => {:original => "500x500>",:default => "120x120>" }

  validates_attachment_presence :photo
  validates_attachment_content_type :photo, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp', 'image/x-png', 'image/pjpeg'], :message => "allow only .jpg, .jpeg, .gif, .bmp, .png formated images"
	# Validation of the size of the attached file
  validates_attachment_size(:photo, :less_than => 25.megabytes)

  has_many :pcategories_products, :dependent => :destroy
  has_many :pcategories, :through => :pcategories_products
  has_many :sent_gifts, :foreign_key => :product_id , :dependent => :destroy


  def add_categories(category_ids="")
    category_ids = category_ids.split(',')
    category_ids.each do |category_id|
      if PcategoriesProduct.find(:first,:conditions=>{:pcategory_id => category_id, :product_id => self.id}).nil?
        self.pcategories_products <<  pcategories_products.build(:product_id => self.id, :pcategory_id => category_id)
      end
    end
    for t_w in self.pcategories_products
      t_w.destroy if (!category_ids.include?(t_w.pcategory_id.to_s) || t_w.pcategory.nil?)
    end

  end

  def humanize_cost
    if self.cost < 1
      return "."+self.cost.to_s.split(".")[1]
    else
      return self.cost
    end
  end
end
