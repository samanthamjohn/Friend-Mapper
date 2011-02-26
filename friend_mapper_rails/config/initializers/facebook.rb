FacebookAuth = Koala::Facebook::OAuth.new(ENV["FB_APP_ID"], ENV["FB_API_SECRET"], ENV["FRIEND_MAPPER_FACEBOOK_URL"]) 
FacebookUrl = FacebookAuth.url_for_oauth_code(:permissions => ['user_location', 'friends_location', 'publish_stream'])
