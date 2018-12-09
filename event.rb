require 'data_mapper' 

if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/event.db")
end

class Event 
    include DataMapper::Resource
    property :id, Serial
    property :name, String #name of event 
    property :description, String # short description of event 
    property :date, String #format 'month/day/year' ex:'november/27/2018'
    property :price, Double #price of each ticket 
    property :quantity, Integer #how many tickets they are purchasing 
    property :tickets, Integer #how many available tickets 
    #need to add an image of an event     

end

get "/events" do

    erb :events

end


DataMapper.finalize
User.auto_upgrade!

