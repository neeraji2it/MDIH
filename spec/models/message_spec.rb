require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  fixtures :messages, :messages_users, :messages_replies, :draft_messages_users

  def message
    SavedSearch.new
  end

  def message_attributes
    {:subject => "Hi how are you?"}
  end

  before(:each) do
    @message = message
  end

  it "should require subject" do
    @message.attributes = message_attributes.except(:subject)
    @message.should have(0).error_on(:subject)
  end

  describe "associations" do

    it "has many messages users" do
      Message.reflect_on_association(:messages_users).to_hash.should == {
        :macro => :has_many,
        :class_name => "MessagesUser",
        :options => {:dependent=>:destroy, :extend=>[]}
      }
    end

    it "has many receivers " do
      Message.reflect_on_association(:receivers).to_hash.should == {
        :macro => :has_many,
        :class_name => "Receiver",
        :options => {:class_name=>"User", :foreign_key=>"to_id", :through=>:messages_users, :extend=>[]}
      }
    end

    it "belongs to user" do
      Message.reflect_on_association(:user).to_hash.should == {
        :macro => :belongs_to,
        :class_name => "User",
        :options => {}
      }
    end

    it "has many draft messages users" do
      Message.reflect_on_association(:draft_messages_users).to_hash.should == {
        :macro => :has_many,
        :class_name => "DraftMessagesUser",
        :options => {:dependent=>:destroy, :extend=>[]}
      }
    end

    it "has many replies" do
      Message.reflect_on_association(:replies).to_hash.should == {
        :macro => :has_many,
        :class_name => "MessagesReply",
        :options => {:class_name=>"MessagesReply", :order => "created_at DESC", :dependent=>:destroy, :extend=>[]}
      }
    end
  end


  describe "methods" do

    it "should return sent messages" do
      Message.sent_messages(1).should == [Message.find(1), Message.find(2)]
    end

    it "should return received messages" do
      Message.received_messages(1).should == [Message.find(1)]
    end

    it "should return unread messages count as array objects" do
      Message.unread_message_count(1).should == []
      Message.unread_message_count(3).should == [Message.find(1)]
    end

    it "should return unread messages count as an integer" do
      Message.unread_count(1).should == 0
      Message.unread_count(3).should == 1
    end

    it "should return messages user object of given user id from receviers list" do
      Message.find(1).my_message_user(2).should == MessagesUser.find(1)
      Message.find(1).my_message_user(3).should == MessagesUser.find(2)
    end

    it "should return latest reply object of a message" do
      Message.find(1).latest_reply.should == MessagesReply.find(1)
      Message.find(2).latest_reply.should == nil
    end

  end
end

