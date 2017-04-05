require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "fwitter_secret"
  end

  helpers do

    def logged_in?
      !!session[:user_id]
    end

    def current_user
      @user = User.find_by(id: session[:user_id])
    end

  end

  get '/' do
    erb :index
  end

  get '/signup' do
    if !logged_in?
      erb :'users/create_user'
    else
      redirect to '/tweets'
    end
  end

  post '/signup' do
    @user = User.new(username: params[:username],
                        email: params[:email],
                     password: params[:password])

    if @user.save
      # TODO: add flash message for successful signup and login
      session[:user_id] = @user.id
      redirect to '/tweets'
    else
      # TODO: add flash message for unsucessful signup
      redirect to '/signup'
    end
  end

  get '/login' do
    if !logged_in?
      erb :'users/login'
    else
      redirect to '/tweets'
    end
  end

  post '/login' do
    @user = User.find_by(username: params[:username])

    if @user && @user.authenticate(params[:password])
      # TODO: add flash message for successful login
      session[:user_id] = @user.id
      redirect to '/tweets'
    else
      # TODO: add flash message for unsucessful login
      redirect to '/login'
    end
  end

  get '/logout' do
    session.clear
    redirect to '/login'
  end


  get '/tweets' do
    if logged_in?
      @tweets = Tweet.all
      erb :'tweets/tweets'
    else
      redirect to '/login'
    end
  end

  get '/tweets/new' do
    if logged_in?
      erb :'tweets/create_tweet'
    else
      redirect to '/login'
    end
  end

  post '/tweets' do
    @tweet = Tweet.create(:content => params[:content])
    @tweet.user = current_user
    if @tweet.save
      redirect to '/tweets'
    else
      redirect to '/tweets/new'
    end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'users/show'
  end

end
