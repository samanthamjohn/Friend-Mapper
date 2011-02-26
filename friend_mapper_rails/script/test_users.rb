#!/usr/bin/env ruby

@test_users = Koala::Facebook::TestUsers.new(:app_id => ENV["FB_APP_ID"], :secret => ENV["FB_API_SECRET"])
@test_users.delete_all
if @test_users.list.size == 0
  @test_users.create_network(10, true, "user_location, friends_location, publish_stream")
  p "success!"
  p @test_users.list.collect{|u| u["login_url"]}
else
  p "test users didn't delete..."
  p @test_users.list.collect{|u| u["login_url"]}
end
