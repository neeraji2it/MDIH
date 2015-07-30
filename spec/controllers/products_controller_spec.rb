require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProductsController do
#  fixtures :products
  def mock_product(stubs={})
    @mock_product ||= mock_model(Product, stubs)
  end

  describe "GET index" do
    it "assigns all products as @products" do
      Product.stub!(:find).with(:all).and_return([mock_product])
      get :index
      assigns[:products].should == nil
    end
  end

  describe "GET new" do
    it "assigns a new product as @product" do
      Product.stub!(:new).and_return(mock_product)
      get :new
      assigns[:product].should  equal(mock_product)
    end
  end
end

