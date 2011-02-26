class Location < ActiveRecord::Base

  def self.add_latlong_worker
    User.add_heroku_worker
    self.delay.add_latlong
  end

  def self.add_latlong
    self.where("latitude" => nil).each do |city|
      city.add_latlong
      sleep(1)
    end
    User.remove_heroku_worker
  end

  def add_latlong
      url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{self.name.gsub(' ', '+')}&sensor=true"
      begin
        res = Net::HTTP.get_response(URI.parse(url))
        location = JSON.parse(res.body)["results"].first["geometry"]["location"]
        self.latitude = location["lat"]
        self.longitude = location["lng"]
        self.save!
      rescue Exception => e
        puts "#{self.name} had an error #{e}"
      end
  end

end
