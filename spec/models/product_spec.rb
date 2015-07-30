require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Product do
  fixtures :products

  def product
    Photo.new
  end

  def product_attributes
    {:photo => url_to_attachment_file('image.png'), :name => "Gift1", :cost => 80}
  end
  
  before(:each) do
    @product = Product.new
  end

  it "should be valid" do
    @product.attributes = product_attributes
    @product.should be_valid
  end

  it "should require name greater than 3 characters" do
    @product.attributes = product_attributes
    @product.name = 'gi'
    @product.should have(1).error_on(:name)
  end

  it "should require name less than 40 characters" do
    @product.attributes = product_attributes
    @product.name = 'sdetctcychchchchchchchchchchchchchhsjsjsaskakalalssssssssaskoksoskkskslkslklasssssdddsddsdsdsdsldksldl'
    @product.should have(1).error_on(:name)
  end

  it "should require cost integer" do
    @product.attributes = product_attributes
    @product.cost = 'sdg'
    @product.should have(1).error_on(:cost)
  end

  it "should require image" do
    @product.attributes = product_attributes.except(:photo)
    @product.should have(1).error_on(:photo)
  end

  it "should photo accept only [jpeg,jpg,png,gif,bmp] formats" do
    %w(image.jpeg image.jpg image.png image.gif image.bmp).each { |image|
      @product.attributes = product_attributes.merge(:photo => url_to_attachment_file(image))}
    @product.should be_valid
  end

  describe "methods" do
    it "should cost return 99 if 99.0" do
      products(:product1).humanize_cost.should == 99
      products(:product2).humanize_cost.should == 98.9
    end
  end
end

