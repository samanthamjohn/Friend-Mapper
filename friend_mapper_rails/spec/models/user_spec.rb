require 'spec/spec_helper'
describe User, :type => :model do
  before(:all) do 
    @test_users = Koala::Facebook::TestUsers.new(:app_id => ENV["FB_APP_ID"], :secret => ENV["FB_API_SECRET"])
    @users = []
    @test_users.list.each do |user|
      new_user = User.add_facebook({'access_token' => user["access_token"], 'expires' => (Time.now + 2.hours)})
      @users.push(new_user)
    end
  end

  it "should save a new user and friends" do 
    @test_users.list.each do |user|
      User.where(:fb_id => user["id"].to_s).first.should_not be_nil
    end
    
  end

  it "should save friend locations" do
    location_array = @users.first.save_friend_locations
    location_array.class.should == Array
    location_array.each do |location|
      locale = Location.where(:name => location[:location]).first
      locale.latitude.should_not be_nil
      locale.name.should_not be_nil
    end
  end
end
