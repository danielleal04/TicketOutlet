require 'data_mapper' # metagem, requires common plugins too.

# need install dm-sqlite-adapter
# if on heroku, use Postgres database
# if not use sqlite3 database I gave you
if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/user.db")
end

#User Table 
class User
    include DataMapper::Resource
    property :id, Serial
    property :email, String
    property :password, String
    property :admin, Boolean, :default => false 

    #######

    ##property :role_id, Integer :default => 0 


    def login(password)
    	return self.password == password
    end
end

#Event Table 
class Event 
    include DataMapper::Resource
    property :id, Serial
    property :name, String #name of event 
    property :description, String # short description of event 
    property :date, String #format 'month/day/year' ex:'november/27/2018'
    property :price, Float #price of each ticket 
    property :quantity, Integer #how many tickets they are purchasing 
    property :tickets, Integer #how many available tickets 
    #need to add an image of an event     

end

#Cart Table - Future Features 
class Cart 
    include DataMapper::Resource
    property :id, Serial 
    property :name, String #name of the event 
    property :cost, Float #sum total of how many tickets purchased 
    property :quantity, Integer # how many tickets purchased 
    
end
### WORK IN PROGRESS ###

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
User.auto_upgrade!
Event.auto_upgrade! 
Cart.auto_upgrade!
