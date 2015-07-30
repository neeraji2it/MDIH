require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessagesUser do
  fixtures :messages_users, :messages
  
  def messages_user
    MessagesUser.new
  end

  def messages_user_attributes
    {:to_id => 2}
  end

  before(:each) do
    @messages_user = messages_user
  end

  it "should require to id" do
    @messages_user.attributes = messages_user_attributes.except(:to_id)
    @messages_user.should have(2).error_on(:to_id)
  end

  it "should require to id integer" do
    @messages_user.attributes = messages_user_attributes.except(:to_id)
    @messages_user.to_id = 'ssss'
    @messages_user.should have(1).error_on(:to_id)
  end

  describe "associations" do
    it "should belongs to message" do
      MessagesUser.reflect_on_association(:receiver).to_hash.should == {
        :macro => :belongs_to,
        :class_name=>"Receiver",
        :options => {:class_name => "User",:foreign_key => "to_id"}
      }
    end

    it "should belongs to message" do
      MessagesUser.reflect_on_association(:message).to_hash.should == {
        :macro => :belongs_to,
        :class_name=>"Message",
        :options => {}
      }
    end
  end
end

