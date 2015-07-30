require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuickMessage do
  fixtures :quick_messages

  def quick_message
    QuickMessage.new
  end

  def quick_message_attributes
    {:message => "sgdg sgdgg sgsgshsh shhhs hsshhsdhs"}
  end

  before(:each) do
    @quick_message = quick_message
  end

  it "should require message" do
    @quick_message.attributes = quick_message_attributes.except(:message)
    @quick_message.should have(1).error_on(:message)
  end
  
  describe "associations" do

    it "belongs to user as sender" do 
      QuickMessage.reflect_on_association(:sender).to_hash.should == {
        :macro => :belongs_to,
        :options => {:class_name => "User", :foreign_key => "from_id"},
        :class_name => "Sender"
      }
    end

    it "belongs to user as receiver" do
      QuickMessage.reflect_on_association(:receiver).to_hash.should == {
        :macro => :belongs_to,
        :options => {:class_name => "User", :foreign_key => "to_id"},
        :class_name => "Receiver"
      }
    end

  end
end