require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SentGift do
  fixtures :sent_gifts

  before(:each) do
    @sent_gift = SentGift.new
  end

  describe "associations" do
     it "belongs to user" do
      SentGift.reflect_on_association(:user).to_hash.should == {
        :macro => :belongs_to,
        :class_name => "User",
        :options => {}
      }
    end

    it "belongs to receiver user" do
      SentGift.reflect_on_association(:receiver).to_hash.should == {
        :macro => :belongs_to,
        :class_name => "Receiver",
        :options => {:foreign_key=>:sent_to, :class_name => "User"}
      }
    end

    it "belongs to product" do
      SentGift.reflect_on_association(:product).to_hash.should == {
        :macro => :belongs_to,
        :class_name => "Product",
        :options => {}
      }
    end
  end
end

