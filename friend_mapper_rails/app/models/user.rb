class User < ActiveRecord::Base
  has_many :friendships, :class_name => "Friendship",   :foreign_key => "user_id"
  has_many :friends, :through => :friendships, :foreign_key => :friend_id, :source => :user

  def self.add_facebook(token_info)
    graph = Koala::Facebook::GraphAPI.new(token_info['access_token'])
    rest = Koala::Facebook::RestAPI.new(token_info['access_token'])
    me = graph.get_object('me')
    @user = User.where("fb_id" => me["id"].to_s).first || User.new
    me["uid"] = me["id"]
    me["current_location"] = me["location"]
    @user.add_facebook(me)
    @user.fb_token = token_info['access_token']
    @user.token_expires = Time.now + token_info['expires'].to_i
    @user.save!
    #self.add_heroku_worker
    #@user.delay.save_friend_locations(graph, rest)
    #return me["location"].inspect
    return @user.save_friend_locations(graph, rest)
  end

  def add_facebook(me)
    self.first_name = me["first_name"] 
    self.last_name = me["last_name"]
    self.fb_id = me["uid"]
    self.location = me["current_location"]["name"] if me["current_location"]
  end

  def save_friend_locations(graph, rest)
    start = Time.now
    friend_locales = rest.fql_query("SELECT uid, first_name, last_name, current_location FROM user WHERE uid IN (select uid2 from friend where uid1=#{self.fb_id} )")
    new_friends = []
    new_friendships = []
    locations = Hash.new{|k,v| k[v] = 0}
    friend_locales.each do |friend| 
      location = friend["current_location"]["name"] if friend["current_location"]
      locations[location] += 1 if location
    end
    locations = locations.sort{|a,b| b[1] <=>a[1]}
    #User.remove_heroku_worker
    return locations[0..19]
  end


  def generate_top_friends_locations
    locations = Hash.new{|k,v| k[v] = 0}
    self.friends.each do |friend|
      locations[friend.location] += 1
    end
    locations.sort{|a, b| a[1] <=> b[1]}
  end

  def self.add_heroku_worker
    heroku = Heroku::Client.new(ENV['HEROKU_USERNAME'], ENV['HEROKU_PASSWORD'])
    heroku.set_workers(ENV['HEROKU_APP'], +1)
  end
  
  def self.remove_heroku_worker
    heroku = Heroku::Client.new(ENV['HEROKU_USERNAME'], ENV['HEROKU_PASSWORD'])
    heroku.set_workers(ENV['HEROKU_APP'], -1)
  end
end
