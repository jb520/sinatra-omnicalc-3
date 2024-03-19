require "sinatra"
require "sinatra/reloader"
require "http"
require "sinatra/cookies"

get("/") do
  erb(:home)
end

get("/umbrella") do
  erb(:umbrella)
end

get("/message") do
  erb(:message)
end

get("/chat") do
  erb(:chat)
end

post("/process_umbrella") do
  @user_location = params.fetch("user_loc")
  # location data
  gmaps_key = ENV.fetch("GMAPS_KEY")
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@user_location}&key=#{gmaps_key}"
  gmaps_data = HTTP.get(gmaps_url).to_s
  gmaps_parse = JSON.parse(gmaps_data)
  results_arr = gmaps_parse.fetch("results")
  first_result_hash = results_arr.at(0)
  geometry_hash = first_result_hash.fetch("geometry")
  location_hash = geometry_hash.fetch("location")
  @lati = location_hash.fetch("lat")
  @long = location_hash.fetch("lng")

  # weather data
  pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
  pirate_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{@lati},#{@long}"
  pirate_data = HTTP.get(pirate_url)
  pirate_parse = JSON.parse(pirate_data)
  currently = pirate_parse.fetch("currently")
  @temp_now = currently.fetch("temperature")
  @summary = currently.fetch("summary")

  hourly = pirate_parse.fetch("hourly")
  hourly_data = hourly.fetch("data")
  next_twelve_hours = hourly_data[1..12]

  precip_threshold = 0.10
  any_precip = false

  next_twelve_hours.each do |hour_hash|
    precip_prob = hour_hash.fetch("precipProbability")

    if precip_prob > precip_threshold
      any_precip = true

      precip_time = Time.at(hour_hash.fetch("time"))

      seconds_from_now = precip_time - Time.now

      hours_from_now = seconds_from_now / 60 / 60

      puts "In #{hours_from_now.round} hours, there is a #{(precip_prob * 100).round}% chance of precipitation."
    end
  end

  if any_precip == true
    @verdict = "You might want to take an umbrella!"
  else
    @verdict = "You probably won't need an umbrella."
  end


  erb(:umbrella_results)
end

post("/process_message") do
  @user_message = params.fetch("user_message")

  request_headers_hash = {
  "Authorization" => "Bearer #{ENV.fetch("OPENAI_KEY")}",
  "content-type" => "application/json"
  }

  request_body_hash = {
  "model" => "gpt-4",
  "messages" => [
    {
      "role" => "system",
      "content" => "You are a helpful assistant."
    },
    {
      "role" => "user",
      "content" => @user_message
    }
  ]
  }

  request_body_json = JSON.generate(request_body_hash)
  raw_response = HTTP.headers(request_headers_hash).post("https://api.openai.com/v1/chat/completions",:body => request_body_json).to_s
  @parsed_response = JSON.parse(raw_response)

  

  erb(:process_message)
end

post("/add_message") do
  erb(:add_message)
end
