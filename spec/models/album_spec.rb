require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Album do
  fixtures :albums

  def album
    Album.new
  end

  def album_attributes
    {:name => "My Album", :description => "My Album"}
  end
  
  before(:each) do
    @album = album
  end

  it "should require name" do
    @album.attributes = album_attributes.except(:name)
    @album.should have(2).error_on(:name)
  end

  it "should require name greater than 3 characters" do
    @album.attributes = album_attributes
    @album.name = 'My'
    @album.should have(1).error_on(:name)
  end

  it "should require name less than than 40 characters" do
    @album.attributes = album_attributes
    @album.name = 'adssdhddfjjeryerywwetsdgsdhsfhjdrtuteredzfdjdtgjutureyweteahsdhsieolijelkgnalggsadgs'
    @album.should have(1).error_on(:name)
  end

  describe "associations" do
    it "belongs to user" do
      Album.reflect_on_association(:user).to_hash.should == {
        :macro => :belongs_to,
        :class_name => "User",
        :options => {}
      }
    end
  end

  it "has many photos" do
    Album.reflect_on_association(:photos).to_hash.should == {
      :macro => :has_many,
      :class_name => "Photo",
      :options => {:order => "created_at DESC", :dependent=>:destroy, :extend=>[]}
    }
  end

  describe "methods" do

    it "should return cover photo" do
      albums(:album1).cover_photo.should == Photo.first
      albums(:album2).cover_photo.should == Photo.find(5)
    end
  end
end

