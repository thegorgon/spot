require 'resque/server'

Spot::Application.routes.draw do    
  scope :module => "api", :constraints => {:subdomain => /api\d*/}, :as => "api" do
    resources :places, :only => [:index] do
      get "search", :on => :collection
    end
    resource :sessions, :only => [:new, :create, :destroy]
    resource :activity, :only => [:show], :controller => "activity"
    resource :wishlist, :only => [:show] do
      resources :items, :only => [:create, :destroy], :controller => :wishlist_items
    end
  end
  
  scope :module => "site", :constraints => {:subdomain => /www|m|app|/} do
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
    end
    get "login" => redirect("/session/new")
    get "register" => redirect("/account/new")
    get "logout", :to => "sessions#destroy"
    get "/!/:id", :to => redirect { |params| ShortUrl.expand(params[:id]) || "/404.html" }, :as => "short"
    get "sitemap(.:format)", :to => "sitemaps#show", :constraints => {:format => :xml}
  end
  
  namespace "admin" do
    resources :places do
      resources :matches, :only => [:index, :create]
      get "matches", :on => :collection
      get "images", :on => :member
    end
    resources :duplicates, :only => [:index] do
      member do 
        put "resolve"
        put "ignore"
      end
    end
    resource :search, :only => [:new, :show], :controller => "search"
    resources :settings, :only => [:index, :create, :update, :destroy] do
      get "available", :on => :collection
    end
    controller "home" do
      get "info"
    end
    root :to => "home#index"
  end
  
  namespace "biz" do
    resource :account, :only => [:new, :create, :show]
    resources :businesses, :only => [:new, :create, :show] do
      get :search, :on => :collection
    end
    controller "home" do
      get "help"
    end
    root :to => "home#index"
  end
  
  mount Resque::Server.new, :at => "/admin/resque"
  
  get "404.html", :to => "site/errors#not_found", :as => "not_found"
  get "422.html", :to => "site/errors#unprocessable", :as => "unprocessable"
  get "500.html", :to => "site/errors#server_error", :as => "server_error"

  root :to => "site/home#index"
  
  match "*path", :to => "site/errors#not_found"
end
