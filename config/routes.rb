require 'resque/server'

Spot::Application.routes.draw do
  if REQUIRE_SSL
    constraints(:protocol => "http://") do
      match "*" => redirect { |params, request|  "https://#{request.host_with_port}#{request.fullpath}" }
      root :to => redirect { |params, request|  "https://#{request.host_with_port}#{request.fullpath}" }
    end
  end
    
  constraints(:protocol => REQUIRE_SSL ? "https://" : "http://") do
    scope :module => "site", :constraints => {:subdomain => /www|m/} do
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
      controller "support" do
        get "about", :action => "about"
        get "press", :action => "press"
        get "getspot", :action => "getspot"
        get "secret", :action => "secret"
      end
      get "login" => redirect("/session/new")
      get "register" => redirect("/account/new")
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
  
    mount Resque::Server.new, :at => "/admin/resque"

    root :to => "site/previews#index"
  end
end
