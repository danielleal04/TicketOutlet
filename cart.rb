require 'data_mapper' 

if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/cart.db")
end

class Cart 
    include DataMapper::Resource
    property :id, Serial 
    property :name, String #name of the event 
    property :cost, Double #sum total of how many tickets purchased 
    property :quantity, Integer # how many tickets purchased 
    
end

DataMapper.finalize
User.auto_upgrade!

