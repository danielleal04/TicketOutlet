require 'sinatra'
require 'sinatra/flash'
require_relative 'event.rb'
require_relative 'authentication.rb'


get "/events" do

    erb :events

end

get "/create_event" do 

    authenticate!
    administrate! 



end 

