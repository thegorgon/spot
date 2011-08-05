require 'resque/server'

Spot::Application.routes.draw do    
  scope :module => "api", :constraints => {:subdomain => /api\d*/}, :as => "api" do
    resources :places, :only => [:index] do
      get "search", :on => :collection
    end
    resources :users, :only => [:update, :show]
    resource :sessions, :only => [:new, :create, :destroy]
    resource :activity, :only => [:show], :controller => "activity"
    resources :notes, :only => [:show, :index, :create, :update, :destroy]
    resource :wishlist, :only => [:show] do
      resources :items, :only => [:create, :destroy], :controller => :wishlist_items
    end
  end
  
  scope :module => "site", :constraints => {:subdomain => /www|m|app|/} do
    resources :blog, :controller => "blog", :only => [:index, :show] do
      get :refresh, :on => :collection, :action => "refresh"
    end
    resources :previews, :only => [:create]
    resource :session, :only => [:new, :create, :destroy]
    resource :account, :only => [:new, :create, :show, :update, :destroy] do
      get "endpoint", :action => "endpoint", :on => :collection
    end
    resource :password_reset, :only => [:new, :create, :edit, :update]
    resources :cities, :only => [:show, :new] do 
      get "calendar", :on => :member
    end
    resource :application, :only => [:create, :show, :new], :controller => "membership_applications"
    resources :registrations, :only => [:show, :create, :destroy]
    resources :places, :only => [:show] do
      resources :events, :only => [:show]
    end
    resource :membership, :only => [:new, :create, :destroy] do 
      get "thanks", :action => "thanks", :on => :member
      get "endpoint", :action => "endpoint", :on => :collection
    end

    resource :widget, :only => [:show]
    resource :email, :only => [:show] do
      delete "unsubscribe"
      get "goodbye"
      get "availability"
      get "existence"
    end
    controller "home" do
      get "about", :action => "about"
      get "privacy", :action => "privacy"
      get "tos", :action => "tos"
      get "press", :action => "press"
      get "getspot", :action => "getspot"
      get "membership/about", :action => "about_membership", :as => "membership_about"
      get "viewemail", :action => "email"
    end
    get "/in", :to => "home#invited", :as => "invitation"
    get "/codes/:type/:code", :to => "codes#show"
    get "login" => redirect("/session/new")
    get "register" => redirect("/account/new")
    get "logout", :to => "sessions#destroy"
    get "/!/:id", :to => redirect { |params| ShortUrl.expand(params[:id]) || "/404.html" }, :as => "short"
    get "sitemap(.:format)", :to => "sitemaps#show", :constraints => {:format => :xml}, :as => "sitemap"
  end
  
  namespace "admin" do
    resources :places do
      resources :matches, :only => [:index, :create]
      get "matches", :on => :collection
      get "images", :on => :member
    end
    resources :applications, :only => [:index], :controller => "membership_applications" do
      put "toggle", :on => :member
    end
    resources :duplicates, :only => [:index] do
      member do 
        put "resolve"
        put "ignore"
      end
    end
    resources :promotions, :only => [:index, :edit, :update] do 
      put "reject", :on => :member
    end
    resources :businesses, :only => [:index] do 
      put "toggle", :on => :member
      put "toggle_account", :on => :member
    end
    resource :search, :only => [:new, :show], :controller => "search"
    resources :settings, :only => [:index, :create, :update, :destroy] do
      get "available", :on => :collection
    end
    controller "home" do
      get "info"
      get "analysis"
    end
    root :to => "home#index"
  end
  
  namespace "biz" do
    resource :account, :only => [:new, :create, :show, :update]
    resources :businesses, :only => [:new, :create, :show, :edit, :update] do
      resources :promotions, :only => [:index, :create, :update, :destroy]
      resources :templates, :path => "promotions/templates", :controller => "promotion_templates", :only => [:index, :create, :update, :destroy]
      resources :codes, :only => [:index, :show], :controller => "promotion_codes" do
        get :lookup, :on => :collection
        get :mail, :on => :collection
        put :redeem, :on => :member
      end
      get :search, :on => :collection
      get :calendar, :on => :member
    end
    resource :contact, :only => [:new, :create]
    controller "home" do
      get "help"
    end
    get "faq", :to => "home#faq"
    get "tos", :to => "home#tos"
    get "widgets", :to => "home#widgets"
    root :to => "home#index"
  end
  
  mount Resque::Server.new, :at => "/admin/resque"
  
  get "upgrade", :to => "site/errors#upgrade", :as => "upgrade"
  get "404.html", :to => "site/errors#not_found", :as => "not_found"
  get "422.html", :to => "site/errors#unprocessable", :as => "unprocessable"
  get "500.html", :to => "site/errors#server_error", :as => "server_error"

  root :to => "site/home#index"
  
  match "*path", :to => "site/errors#not_found"
end
