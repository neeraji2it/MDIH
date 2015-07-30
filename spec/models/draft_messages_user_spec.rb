require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DraftMessagesUser do
  fixtures :draft_messages_users
  
#  before(:each) do
#    @draft_messages_user = DraftMessagesUser.new
#  end

  describe "associations" do

    it "belongs to user" do
      DraftMessagesUser.reflect_on_association(:message).to_hash.should == {
        :macro => :belongs_to,
        :class_name => "Message",
        :options => {}
      }
    end

    it "belongs to user" do
      DraftMessagesUser.reflect_on_association(:user).to_hash.should == {
        :macro => :belongs_to,
        :class_name => "User",
        :options => {:foreign_key => "to_id"}
      }
    end
  end
end

