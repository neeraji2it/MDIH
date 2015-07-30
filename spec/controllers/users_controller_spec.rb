require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  controller_name :users
  fixtures :users

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
  end

  before(:each) do
    controller.send(:current_user=, users(:luc))
  end

  describe "responding to GET new" do
    it "should  get new user object" do
      User.stub!(:new).and_return(mock_user)
      get :new
    end
  end

  describe "POST to create" do
    before(:each) do
      @parameters = {"user"=>{"zip"=>"123456", "password_confirmation"=>"monkey", "gender"=>"Male", "last_name"=>"Boss", "date_of_birth(1i)"=>"1992", "date_of_birth(2i)"=>"5", "password"=>"monkey", "login"=>"boss", "date_of_birth(3i)"=>"4", "middle_name"=>"", "first_name"=>"MDIH", "email"=>"admin@mdih.com"}}
      @wrong_parameters = {"user" => {}}
    end
    it "should receive user details as parameters" do
      @parameters.should == {"user"=>{"zip"=>"123456", "password_confirmation"=>"monkey", "gender"=>"Male", "last_name"=>"Boss", "date_of_birth(1i)"=>"1992", "date_of_birth(2i)"=>"5", "password"=>"monkey", "login"=>"boss", "date_of_birth(3i)"=>"4", "middle_name"=>"", "first_name"=>"MDIH", "email"=>"admin@mdih.com"}}
    end
    describe "with valid params" do
      it "should send activation email and redirect to / if user saved successfully" do
        @user = User.new(@parameters)
        User.stub!(:new).and_return(@user)
        UserMailer.stub!(:deliver_activation_notification).with(@user)
        post :create
        #        response.should redirect_to('/')
      end
    end
  end

  describe "GET to activate" do
    it "should receive activation key" do
      User.should_receive(:find).with(:first, {:conditions=>{:activation_code=>nil}}).and_return(mock_user)
#      mock_user.delete_activation_code.and_return(true)

      get :activate
      response.should redirect_to('/')
    end
    
  end
end

