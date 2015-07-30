require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessagesReply do
  fixtures :messages_replies

def messages_reply
    MessagesReply.new
  end

  def messages_reply_attributes
    {:body => "Good morning."}
  end

  before(:each) do
    @messages_reply = MessagesReply.new
  end

  it "should require bodt" do
    @messages_reply.attributes = messages_reply_attributes.except(:body)
    @messages_reply.should have(1).error_on(:body)
  end

  describe "associations" do

    it "belongs to user" do
      MessagesReply.reflect_on_association(:user).to_hash.should == {
        :macro => :belongs_to,
        :class_name => "User",
        :options => {}
      }
    end

    it "belongs to user" do
      MessagesReply.reflect_on_association(:message).to_hash.should == {
        :macro => :belongs_to,
        :class_name => "Message",
        :options => {}
      }
    end
  end
end

