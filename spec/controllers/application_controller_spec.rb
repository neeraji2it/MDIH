require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

  describe "before filters" do

    it "should have a filter for checking if user is logged in" do
      ApplicationController.before_filters.should include(:is_logged?)
    end

  end

end

