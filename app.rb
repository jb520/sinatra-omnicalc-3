require "sinatra"
require "sinatra/reloader"
require "http"

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

get("/process_umbrella") do
  @user_location = params.fetch("user_loc")
  gmaps_key = ENV.fetch("GMAPS_KEY")
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps_key}"
  gmaps_data = HTTP.get(gmaps_url).to_s
  #gmaps_parse = JSON.parse(gmaps_data)


  erb(:umbrella_results)
end

get("/process_message") do
  erb(:process_message)
end

get("/add_message") do
  erb(:add_message)
end
