require 'sinatra'
require 'sinatra/flash'
require_relative "user.rb"

enable :sessions

set :session_secret, 'super secret'

get "/login" do

	InvalidLogin = false 
	erb :"authentication/login"
end

get "/login/fail" do 

	InvalidLogin = true 
	erb :"authentication/login" 

end 

post "/process_login" do
	email = params[:email]
	password = params[:password]

	user = User.first(email: email.downcase)

	if(user && user.login(password))
		session[:user_id] = user.id

		flash[:success]= "Successfully Logged In"
		redirect "/home"
	else
		flash[:error]= "Invalid Email or Password"
		redirect "/login/fail"
	end
end

get "/logout" do
	session[:user_id] = nil
	redirect "/home"
end

get "/sign_up" do
	erb :"authentication/sign_up"
end


post "/register" do
	email = params[:email]
	password = params[:password]

	u = User.new
	u.email = email.downcase
	u.password =  password
	u.save

	session[:user_id] = u.id

	erb :"authentication/successful_signup"

	flash[:success]= "Account Successfully Created"
	redirect"/home"  

end

#This method will return the user object of the currently signed in user
#Returns nil if not signed in
def current_user
	if(session[:user_id])
		@u ||= User.first(id: session[:user_id])
		return @u
	else
		return nil
	end
end

#if the user is not signed in, will redirect to login page
def authenticate!
	if !current_user
		redirect "/login"
	end
end
