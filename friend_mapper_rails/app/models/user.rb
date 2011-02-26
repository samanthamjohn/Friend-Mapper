class User < ActiveRecord::Base

  def self.add_facebook(token_info)
    graph = Koala::Facebook::GraphAPI.new(token_info['access_token'])
    p token_info.inspect
    me = graph.get_object('me')
    @user = User.where("fb_id" => me["id"].to_s).first || User.new
    @user.add_facebook(me)
    @user.fb_token = token_info['access_token']
    @user.token_expires = Time.now + token_info['expires'].to_i
    @user.save!
    return @user
    #return me["location"].inspect
    #return @user.save_friend_locations(graph, rest)
  end

  def add_facebook(me)
    self.first_name = me["first_name"] 
    self.last_name = me["last_name"]
    self.fb_id = me["id"]
    self.location = me["location"]["name"] if me["location"]
  end

  def save_friend_locations
    rest = Koala::Facebook::RestAPI.new(self.fb_token)
    friend_locales = rest.fql_query("SELECT uid, pic_square, first_name, last_name, current_location FROM user WHERE uid IN (select uid2 from friend where uid1=#{self.fb_id} )")
    locations = Hash.new{|k,v| k[v] = {:no_users => 0, :names => []}}

  
    friend_locales.each do |friend| 
      location = friend["current_location"]["name"] if friend["current_location"] != nil
      locations[location][:no_users] += 1 if location
      name = "#{friend["first_name"].gsub(' ', '_')}_#{friend["last_name"].gsub(' ', '_')}"
      locations[location][:names].push("#{friend["uid"]},#{name},#{friend["pic_square"]}")
    end
    #User.add_heroku_worker
    locations_array = Location.find(:all, :conditions => ["name in (?) AND latitude IS NOT NULL AND longitude IS NOT NULL", locations.keys], :select => ["latitude, longitude, name"])
    location_names_array = locations_array.collect{|l| l.name}
    locations_array = locations_array.collect{|l| {:location => l.name, :latitude => l.latitude, :longitude => l.longitude, :no_friends => locations[l.name][:no_users], :names =>locations[l.name][:names]}}
    locations.keys.each do |locale|
      
      if (locale && !(location_names_array.include?(locale)))
        location = Location.where(:name => locale).first ||  Location.new(:name => locale)
        location.add_latlong if (location.latitude.nil? || location.longitude.nil?)
        locations_array.push({:location => locale, :latitude => location.latitude, :longitude => location.longitude, :no_friends => locations[locale][:no_users], :names => locations[locale][:names]})
      end
    end
    return locations_array#.sort{|a,b| b[:no_friends] <=>a[:no_friends]}
  end

  def save_locations(friend_locales)
    locations = []
    friend_locales.each do |friend| 
      locations.push(Location.new(:name => friend["current_location"]["name"]) ) if friend["current_location"]
    end
    Location.import locations
    User.remove_heroku_worker
  end

  def wall_post
    graph = Koala::Facebook::GraphAPI.new(self.fb_token)
    graph.put_wall_post("", {:name => "Friend Mapper", :description=> "Find out! Friend Mapper creates a map showing you the cartography of your friendships.", :caption => "what's the most unexpected place you have a friend?", :picture => "http://175jay.com/friendmapper/images/red_map.png", :link => "http://apps.facebook.com/friends_mapper"})
  end

  def map
    @address_list = save_friend_locations  

    @map = Cartographer::Gmap.new( 'map' )
    @map.controls << :type
    @map.controls << :large
    @map.controls << :scale
    @map.controls << :overview
    @map.zoom = :bound
    marker_icon = Cartographer::Gicon.new(:name => "org",
          :image_url => "http://thydzik.com/thydzikGoogleMap/markerlink.php?text=%20&color=3B5998", 
          :width => 32,
          :height => 23,
          :shadow_width => 32,
          :shadow_height => 23,
          :anchor_x => 0,
          :anchor_y => 20,
          :info_anchor_x => 5,
          :info_anchor_y => 1)
    @map.icons << marker_icon
    markers = []
    @address_list.each_with_index do |address, i|
      if (address[:longitude] && address[:latitude])
        friends = ""
        address[:names].collect{|name| friends << "#{name} "}
        info_window =  "/users/sample_ajax/?location=#{address[:location]}&names=#{friends}"
        markers[i] = Cartographer::Gmarker.new(:name=> "marker_#{i}", :marker_type => "Building",:position => [address[:latitude],address[:longitude]], :info_window_url =>info_window, :icon => marker_icon) 
        @map.markers << markers[i]
      end
    end
    return @map
  end

  def generate_content_string(address)
    address_names = ""
    address[:names].each{|name| address_names<<("<li>#{name}</li>")} 
    contentString = "<h3>#{address["location"]}</h3> <ul>#{address_names}</ul>"
    return contentString
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
