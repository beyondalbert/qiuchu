require 'sinatra/base'
require 'sinatra/activerecord'
require 'json'
require 'bcrypt'
require 'mini_magick'

class ApplicationController < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  helpers ApplicationHelper

  set :views, File.expand_path('../../views', __FILE__)
  set :database, "mysql2://root:@localhost/qiuchu"

  configure :production, :development do
    enable :logging
    enable :sessions

    # setting app log
    Logger.class_eval { alias :write :'<<' }
    logger = Logger.new("log/#{settings.environment}.log")
    use Rack::CommonLogger, logger
  end

  before '/pictures/:id' do
	@current_user ||= User.find_by_token(params[:key]) unless params[:key].nil?
    error 401 unless @current_user
  end

  get '/signup' do
    erb :signup
  end

  post '/signup' do
    @user = User.new(:email => params[:user][:email])
    @user.password_salt = BCrypt::Engine.generate_salt
    @user.password_hash = BCrypt::Engine.hash_secret(params[:user][:password], @user.password_salt)
    @user.token = SecureRandom.hex

    if @user.save
      session[:user] = @user.token
      redirect '/'
    else
      redirect "/signup?email=#{params[:user][:email]}"
    end
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    if @user = User.find_by_email(params[:email])
      if @user.password_hash == BCrypt::Engine.hash_secret(params[:password], @user.password_salt)
        session[:user] = @user.token
        redirect '/'
      else
        redirect "/login?email=#{params[:email]}"
      end
    else
      redirect "/login?email=#{params[:email]}"
    end
  end

  get '/logout' do
    session[:user] = nil
    redirect '/'
  end

  get '/forget_passowrd' do
    erb :forget_passowrd
  end

  post '/forget_passowrd' do
    #TO DO
  end

  get '/change_password' do
    if login?
      erb :change_password
    else
      redirect "/login"
    end
  end

  post '/change_password' do
    @user = current_user
    if @user.password_hash == BCrypt::Engine.hash_secret(params[:old_password], @user.password_salt)
      @user.password_hash = @user.password_hash = BCrypt::Engine.hash_secret(params[:new_password], @user.password_salt)    
      if @user.save
        redirect '/'
      else
        redirect "/change_password"
      end
    else
      redirect "/change_password"
    end
  end

  get '/' do
    @user = session[:user]
    erb :welcome
  end
end
