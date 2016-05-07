ENV["RACK_ENV"] ||= "development"

require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/partial'

require_relative 'data_mapper_setup'
require_relative 'models/peep'
require_relative 'models/user'

class ChitterChallenge < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  register Sinatra::Partial
  use Rack::MethodOverride
  set :session_secret, 'super secret'
  set :partial_template_engine, :erb

  enable :partial_underscores

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end
  get '/' do
    'Hello ChitterChallenge!'
  end

  get '/peeps' do
  	@peeps = Peep.all
  	erb:'peeps/index'
  end

  post '/peeps' do
  	Peep.create(peep: params[:peep])
  	redirect '/peeps'
  end

  get '/peeps/new' do
  	erb:'peeps/new'
  end

  get '/users/new' do
    @user = User.new
    erb:'users/new'
  end

  post '/users' do  
    @user = User.create(email: params[:email],
                    password: params[:password],
                    password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect '/peeps'
    else
      flash.now[:errors] = @user.errors.full_messages
      erb:'users/new'
    end
  end
  # start the server if ruby file executed directly
  run! if app_file == $0
end
