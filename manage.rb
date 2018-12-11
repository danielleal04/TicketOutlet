require 'sinatra'
require 'sinatra/flash'
require_relative 'data.rb'
require_relative 'authentication.rb'
require 'stripe'

#Stripe Stuff 
	set :publishable_key, ENV['PUBLISHABLE_KEY']
	set :secret_key, ENV['SECRET_KEY'] 

	#Stripe.api_key = settings.secret_key
	Stripe.api_key = 'sk_test_nOTfcqXg3cO7HGy7NQFTI9jn'
	settings.publishable_key = 'pk_test_Ml2UTDzqhLMH9krsoVD6ZlWZ'
#############

get "/events" do

	@event = Event.all 

    erb :events

end

get "/add_event" do 

    authenticate!
    administrate! 

    erb :create_event 

end 

post "/create_event" do 

	new_event = Event.new 

	new_event.event_name = params[:event_name].to_s
	new_event.event_description = params[:event_description].to_s

	edit_date = params[:event_date].to_s
	edit_date.delete!("-")
	new_event.event_date = Date.parse(edit_date).strftime("%m/%d/%Y").to_s  #=> "02/25/2012"

	new_event.event_price = params[:event_price].to_f 
	new_event.avai_tickets = params[:avai_tickets].to_i 
	new_event.image_name = ("/" + params[:image_name] + ".jpg/").to_s

	new_event.save 

	flash[:success]= "Event Successfully Created"
	redirect"/events" 
end 

get "/purchase" do 

	authenticate!

	@event = Event.first(id: params[:event]) 

	erb :purchase

# make a post request to charge in purchase  

end 

post '/charge' do
  # Amount in cents
  @amount = 500

  customer = Stripe::Customer.create(
    :email => 'customer@example.com',
    :source  => params[:stripeToken]
  )

  charge = Stripe::Charge.create(
    :amount      => @amount,
    :description => 'Sinatra Charge',
    :currency    => 'usd',
    :customer    => customer.id
  )

  erb :charge #successful 

  current_user.pro = true 
  current_user.save 

end
