require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  fixtures :roles, :users, :profiles, :imported_contacts, :friends_users, :profile_viewers
  def user
    User.new
  end

  def user_attributes
    {
      :login => "boss",
      :email => "boss@mdih.com", 
      :first_name =>"Mdih",
      :last_name => "Boss",
      :password => "bangalore",
      :password_confirmation => "bangalore",
      :date_of_birth => (Date.today - (364 * 25)),
      :role_id => 1,
      :status => true
    }
  end

  before(:each) do
    @user = user
  end

  it "should be valid" do
    @user.attributes = user_attributes
    @user.should be_valid
  end

  it "should require login" do
    @user.attributes = user_attributes.except(:login)
    @user.should have(3).error_on(:login)
  end

  it "should require a unique login" do
    @user.attributes = user_attributes
    @user.login = 'luc'
    @user.should have(1).error_on(:login)
  end

  it "should require login greater than 3 characters" do
    @user.attributes = user_attributes
    @user.login = 'lu'
    @user.should have(1).error_on(:login)
  end

  it "should require login less than 40 characters" do
    @user.attributes = user_attributes
    @user.login = 'luctctcychchchchchchchchchchchchchhsjsjsaskakalalssssssssaskoksoskkskslkslklasssssdddsddsdsdsdsldksldl'
    @user.should have(1).error_on(:login)
  end

  it "should require login without special characters" do
    @user.attributes = user_attributes
    @user.login = 'luc[]'
    @user.should have(1).error_on(:login)
  end

  it "should require password" do
    @user.attributes = user_attributes.except(:password)
    @user.should have(3).errors_on(:password)
  end

  it "should require confirmation password" do
    @user.attributes = user_attributes.except(:password_confirmation)
    @user.should have(1).errors_on(:password_confirmation)
  end

  it "should require confirmation password same as password" do
    @user.attributes = user_attributes
    @user.password_confirmation = 'gsaggs'
    @user.should have(1).error_on(:password)
  end

  it "should require email" do
    @user.attributes = user_attributes.except(:email)
    @user.should have(3).errors_on(:email)
  end

  it "should require email greater than 6 characters" do
    @user.attributes = user_attributes
    @user.email = 'ad'
    @user.should have(2).error_on(:email)
  end

  it "should require email less than than 100 characters" do
    @user.attributes = user_attributes
    @user.email = 'adssdhddfjjeryerywwetsdgsdhsfhjdrtuteredzfdjdtgjutureyweteahsdhsieolijelkgnalggsadgs'
    @user.should have(1).error_on(:email)
  end
  
  it "should require unique email" do
    @user.attributes = user_attributes
    @user.email = 'luc@mdih.com'
    @user.should have(1).error_on(:email)
  end

  it "should require email with proper format" do
    @user.attributes = user_attributes
    @user.email = 'lucgmailcom'
    @user.should have(1).error_on(:email)
  end

  it "should require first name" do
    @user.attributes = user_attributes.except(:first_name)
    @user.should have(2).errors_on(:first_name)
  end

  it "should require date of birth" do
    @user.attributes = user_attributes.except(:date_of_birth)
    @user.should have(1).errors_on(:date_of_birth)
  end
  
  describe "associations" do

    it "belongs to role" do
      User.reflect_on_association(:role).to_hash.should == {
        :macro => :belongs_to,
        :options => {},
        :class_name => "Role"
      }
    end
    
    it "has one users profile" do
      User.reflect_on_association(:profile).to_hash.should == {
        :macro => :has_one,
        :options => {:dependent => :destroy},
        :class_name => "Profile"
      }
    end


    #    it "has and belongs to many friens" do
    #      User.reflect_on_association(:friends).to_hash.should == {
    #        :macro => :has_and_belongs_to_many,
    #        :options => {:class_name => "User", :association_foreign_key => "friend_id", :join_table => "friends", :uniq => true,
    #                     :delete_sql =>'DELETE FROM friends WHERE user_id = #{id} or friend_id = #{id}', :extend => []},
    #        :class_name => "Friend"
    #      }
    #    end
    it "has many frieds users" do
      User.reflect_on_association(:friends_users).to_hash.should == {
        :macro => :has_many,
        :class_name=>"FriendsUser",
        :options => {
          :dependent => :destroy, :extend=>[]
        }
      }
    end

    it "has many friends thriugh friends users" do
      User.reflect_on_association(:friends).to_hash.should == {
        :macro=>:has_many,
        :class_name => "Friend",
        :options => {
          :through => :friends_users, :conditions=>["friends_users.status = 'accepted'"], :class_name=>"User", :extend=>[]
        }
      }
    end

    it "has many requested friends" do
      User.reflect_on_association(:requested_friends).to_hash.should == {
        :macro=>:has_many,
        :class_name=>"RequestedFriend",
        :options=>{
          :source=>:friend, :class_name=>"User", :through=>:friends_users,
          :extend=>[], :conditions=>["friends_users.status = 'pending'"]
        }
      }
    end

    it "has many imported contacts" do
      User.reflect_on_association(:imported_contacts).to_hash.should == {
        :macro => :has_many,
        :options => {:order => 'email ASC', :dependent => :destroy, :extend => []},
        :class_name => "ImportedContact"
      }
    end


    it "has and belongs to many  profiles viewed" do
      User.reflect_on_association(:profile_viewed).to_hash.should == {
        :macro => :has_and_belongs_to_many,
        :class_name => "ProfileViewed",
        :options => {:class_name => "User",:foreign_key => "viewed_by", :association_foreign_key => "user_id",
          :join_table => "profile_viewers", :order =>"viewed_at DESC", :uniq => true,
          :delete_sql =>'DELETE FROM profile_viewers WHERE user_id = #{id} or viewed_by = #{id}', :extend => [],
          :select=>"users.*", :uniq=>true, :order=>"viewed_at DESC"
        }
        
      }
    end

    it "has and belongs to many profile viewed by" do
      User.reflect_on_association(:profile_viewed_by).to_hash.should == {
        :macro => :has_and_belongs_to_many,
        :class_name => "ProfileViewedBy",
        :options => {:class_name => "User", :association_foreign_key => "viewed_by",
          :join_table => "profile_viewers", :order =>"viewed_at DESC", :uniq => true, :extend => [], 
          :select => "users.*", :order =>"viewed_at DESC", :uniq => true
        }
      }
    end

    it "has many quicek messages" do
      User.reflect_on_association(:quick_messages).to_hash.should == {
        :macro => :has_many,
        :options => {:foreign_key => "to_id", :order => "sent_on DESC", :dependent => :destroy, :extend => []},
        :class_name => "QuickMessage"
      }
    end

    it "has many saved searches" do
      User.reflect_on_association(:saved_searches).to_hash.should == {
        :macro => :has_many,
        :class_name=>"SavedSearch",
        :options=>{:extend=>[], :dependent=>:destroy}
      }
    end

    it "has many in messages" do
      User.reflect_on_association(:in_messages).to_hash.should == {
        :macro => :has_many,
        :class_name=>"InMessage",
        :options=>{:class_name=>"MessagesUser", :order => "created_at DESC", :foreign_key => "to_id", :dependent=>:destroy, :extend=>[]}
      }
    end

    it "has many messages" do
      User.reflect_on_association(:messages).to_hash.should == {
        :macro => :has_many,
        :class_name=>"Message",
        :options=>{:extend=>[], :dependent=>:destroy}
      }
    end

    it "has many messages" do
      User.reflect_on_association(:sent_messages).to_hash.should == {
        :macro => :has_many,
        :class_name=>"Message",
        :options=>{:class_name=>"Message", :order => "created_at DESC", :conditions => ["message_type = 'sent'"], :extend=>[], :dependent=>:destroy}
      }
    end

    it "has many droft messages" do
      User.reflect_on_association(:draft_messages).to_hash.should == {
        :macro => :has_many,
        :class_name=>"Message",
        :options=>{:class_name=>"Message", :order => "created_at DESC", :conditions => ["message_type = 'draft'"], :extend=>[], :dependent=>:destroy}
      }
    end

    it "has many sent gifts" do
      User.reflect_on_association(:sent_gifts).to_hash.should == {
        :macro => :has_many,
        :class_name=>"SentGift",
        :options=>{:extend=>[], :dependent=>:destroy, :conditions=>["sender_status != 'deleted'"]}
      }
    end

    it "has many received gifts" do
      User.reflect_on_association(:received_gifts).to_hash.should == {
        :macro => :has_many,
        :class_name=>"SentGift",
        :options=>{:class_name=>"SentGift", :foreign_key => :sent_to, :extend=>[], :dependent=>:destroy, :conditions=>["receiver_status != 'deleted'"]}
      }
    end

    it "has many albums" do
      User.reflect_on_association(:albums).to_hash.should == {
        :macro => :has_many,
        :class_name=>"Album",
        :options=>{:order=>"updated_at DESC", :extend=>[], :dependent=>:destroy}
      }
    end

    it "has many photos" do
      User.reflect_on_association(:photos).to_hash.should == {
        :macro => :has_many,
        :class_name=>"Photo",
        :options=>{:order=>"created_at DESC", :extend=>[], :dependent=>:destroy}
      }
    end

    it "has many my blocked users" do
      User.reflect_on_association(:my_blocked_users).to_hash.should == {
        :macro => :has_many,
        :class_name=>"MyBlockedUser",
        :options=>{:source=>:blocked_user, :class_name=>"BlockedUser", :foreign_key => "user_id", :extend=>[], :dependent=>:destroy}
      }
    end

    it "has many blocked users" do
      User.reflect_on_association(:blocked_users).to_hash.should == {
        :macro => :has_many,
        :class_name=>"BlockedUser",
        :options=>{:through => :my_blocked_users, :class_name=>"User", :extend=>[] }
      }
    end

    it "has many my match users" do
      User.reflect_on_association(:my_match_users).to_hash.should == {
        :macro => :has_many,
        :class_name=>"MyMatch",
        :options=>{:source=>:matcher, :foreign_key=>"user_id", :class_name=>"MyMatch", :extend=>[], :dependent=>:destroy}
      }
    end

    it "has many my matches " do
      User.reflect_on_association(:my_matches).to_hash.should == {
        :macro => :has_many,
        :class_name=>"MyMatch",
        :options=>{:through => :my_match_users, :class_name=>"User", :source => :matcher, :extend=>[] }
      }
    end
  end

  describe "methods" do

    it "should return contacted user ids" do
      users(:luc).contacted_user_ids.should == [2, 3]
    end

    it "should return true if user role name is admin else false" do
      users(:luc).is_admin?.should == true
      users(:lud).is_admin?.should == false
    end

    it "should return latest matched user" do
      users(:luc).my_latest_match_user.should == User.find(2)
    end

    it "should return full name" do
      users(:luc).full_name.should == 'Luc  Luc'
    end

    it "should return age of the user in integer format" do
      users(:luc).age.should == 25
    end

    it "should return user's gender Man/Women" do
      users(:luc).humanized_gender.should == "Man"
      users(:lud).humanized_gender.should == "Women"
    end
    
  end

end
