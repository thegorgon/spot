require 'resque/server'

Spot::Application.routes.draw do  
  scope :module => "site" do
    resources :previews, :only => [:index, :create] do
      get "share"
    end
    resources :blog, :controller => "blog", :only => [:index]
    resource :session, :only => [:new, :create, :destroy]
    resource :account, :only => [:new, :create, :destroy]
    resource :password_reset, :only => [:new, :create, :edit, :update]
    resources :places, :only => [:show]
    resource :email, :only => [:show] do
      delete "unsubscribe"
      get "goodbye"
      get "availability"
      get "existence"
    end
    controller "home" do
      get "about", :action => "about"
      get "press", :action => "press"
      get "getspot", :action => "getspot"
      get "secret", :action => "secret"
    end
    get "login" => redirect("/session/new")
    get "register" => redirect("/account/new")
    match "/!/:id", :to => redirect(:status => 301) { |params| ShortUrl.expand(params[:id]) }
  end
  
  scope :module => "api", :constraints => {:subdomain => /api\d*/}, :as => "api" do
    resources :places, :only => [:index] do
      collection do 
        get "search"
      end
    end
    resource :sessions, :only => [:new, :create, :destroy]
    resource :activity, :only => [:show], :controller => "activity"
    resource :wishlist, :only => [:show] do
      collection do
        get "activity"
      end
      resources :items, :only => [:create, :destroy], :controller => :wishlist_items
    end
  end
  
  namespace "admin" do
    resources :places do
      resources :matches, :only => [:index, :create]
      member do
        get "images"
      end
    end
    resources :duplicates, :only => [:index] do
      member do 
        put "resolve"
        put "ignore"
      end
    end
    resource :search, :only => [:new, :show], :controller => "search"
    controller "home" do
      get "info"
    end
    root :to => "home#index"
  end
  
  namespace "biz" do
    resource :account, :only => [:new, :show]

    controller "home" do
      get "help"
    end
    root :to => "home#index"
  end
  
  mount Resque::Server.new, :at => "/admin/resque"
  
  get "error",    :to => "site/errors#error_test"
  get "404.html", :to => "site/errors#not_found", :as => "not_found"
  get "422.html", :to => "site/errors#unprocessable", :as => "unprocessable"
  get "500.html", :to => "site/errors#server_error", :as => "server_error"
  
  root :to => "site/home#index"  
  
  match "*path", :to => "site/errors#not_found"
end
