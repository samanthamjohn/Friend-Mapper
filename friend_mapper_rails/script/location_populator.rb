#!/usr/bin/env ruby
locations = []
# Download spreadsheet of us cities from Jocelyn's server
url = "http://175jay.com/friendmapper/us_cities.csv"
world_cities = []
res = Net::HTTP.get_response(URI.parse(url))
res.body.each_line do |f| 
  locations = f.split("\r")
end

locations = locations.collect{|l| l.split(',')}
data = []
locations.each do |locale|
  location_name = "#{locale[1]}, #{locale[0]}"
  data.push([locale[0], locale[1], locale[2], locale[3], location_name, "US"])
end

# Add info to db via activerecord import
columns = ["state", "city", "latitude", "longitude", "name", "country", "created_at", "updated_at"]
location1 = data[0..10000]
Location.import(columns, location1)
location2 = data[10001..20000]
Location.import(columns, location2)
location3 = data[20001..30000]
Location.import(columns, location3)

# Download world city name from Jocelyn's server
url = "http://175jay.com/friendmapper/world_cities.csv"
world_cities = []
res = Net::HTTP.get_response(URI.parse(url))
res.body.each_line do |f| 
  world_cities.push(f.gsub("\r\n", "").split(','))
end

new_cities = []
world_cities.each do |city|
  city = city.collect{|c| c.strip}
  if city[1] != "United States"
    if city[0].include?('(')
      new_city = city[0].split('(')
      new_cities.push([new_city[0], city[1], "#{new_city[0]}, #{city[1]}"])
      new_cities.push([new_city[1].gsub(')', ''), city[1], "#{new_city[1].gsub(')', '')}"])
    else
      new_cities.push([city[0], city[1], "#{city[0]}, #{city[1]}"])
    end
  end
end

# Add world city names to db via activerecord import
columns = ["city", "country", "name"]
data = new_cities
Location.import(columns, data)


