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

	authenticate!
	administrate! 

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

end 

post '/payment' do 

	authenticate! 

	@event = Event.first(id: params[:event])

	if params[:tickets_purchasing].to_i > @event.avai_tickets 

		flash[:error] = "Event Tickets Unavailable"
		redirect "/events"

	end 

	cart = Cart.new 
	cart.tickets_purchasing = params[:tickets_purchasing]
	cart.name = @event.event_name
	cart.user_id = (current_user.id) 
	cart.event_id = @event.id.to_i
	cart.cost  = ( (@event.event_price.to_f * params[:tickets_purchasing].to_f).to_f ).round(2) 
	cart.display_total = ( cart.cost * 100 ).round(2) 
	cart.save 

	redirect "/cart"

end 

get '/cart' do 

	authenticate! 
	current = (current_user.id)
	@cart = Cart.all(user_id: current)

	@total = add_all_cart(false)
	@display_total = add_all_cart(true)

	erb :total

end 

post '/charge' do
  # Amount in cents
  @amount = add_all_cart(true)

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

  # deduct tickets purchased with total tickets available 
  # empty cart 

end

def add_all_cart (display) 

	current = (current_user.id)
	@cart = Cart.all(user_id: current)

	@total = 0.00
	@display_total = 0.00

	@cart.each do |item| 

		@total += item.cost 
		@display_total += item.display_total 

	end 

	if display 
		return @display_total 
	else 
		return @total
	end 

end 
