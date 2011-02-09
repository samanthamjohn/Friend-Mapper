FacebookTokens = YAML::load(File.open("#{::Rails.root.to_s}/config/facebook.yml"))
FacebookAuth = Koala::Facebook::OAuth.new(FacebookTokens["app_id"], FacebookTokens["app_secret"], FacebookTokens["app_url"]) 
Permissions = ['user_location', 'friends_location', 'publish_stream']
