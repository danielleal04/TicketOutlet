require 'sinatra'
require 'sinatra/flash'
require_relative 'user.rb'

enable :sessions

set :session_secret, 'super secret'

#######
if User.all(admin: true).count == 0
    u = User.new
    u.email = "admin@admin.com"
    u.password = "admin"
    u.admin = true
    u.save
end
#######

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

	flash[:success]= "Account Successfully Created"
	redirect"/home"  

end


get "/forgotpassword" do

	erb :forgotpass

end

######

# Global Variable to change password 
# prototype 

$temp_email = "" 
$temp_pass = 0

######

post "/newpassword" do
	
	input_email = params[:email] 

	user = User.first(email: input_email.downcase)

	if user

		$temp_email = input_email

		$temp_pass = 1
		redirect "newpasswordform"

	else 
		flash[:error]= "Invalid Email"
		redirect "/forgotpassword"
	end 

end

get "/newpasswordform" do

	if $temp_pass == 1

		InvalidPasswords = false 
		$temp_pass = 0 
		erb :newpass 

	else 

		redirect "/forgotpassword"

	end 

end 

get "/newpasswordform/fail" do

	if $temp_pass == 1

		InvalidPasswords = true 
		$temp_pass = 0 
		erb :newpass 

	else 

		redirect "/forgotpassword"

	end 

end 

post "/updatepassword" do 

	#check if both passworf and confirm password match 
	p1 = params[:password]
	p2 = params[:confirmpassword]

	if p1 != p2 

		flash[:error]= "Passwords Must Both Match"
		$temp_pass = 1 
		redirect "/newpasswordform/fail"

	else 

		#make change
		new_password = params[:confirmpassword]

		user = User.first(email: $temp_email.downcase)

		user.password = new_password
		user.save 

		$temp_email = ""  # clears 

		flash[:success]= "Password Changed" 
		redirect"/home"  

	end 

end 

get "/profile" do
	
	authenticate! 

	erb :profile

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

#if the user is not admin, will redirect to home page 
def administrate!
	if current_user.admin == false 
		redirect "/home"
	end
end


