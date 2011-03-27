Spot::Application.routes.draw do
  scope :module => "site", :constraints => {:subdomain => /www|m/} do
    resources :previews, :only => [:index, :create] do
      get "share"
    end
    resources :blog, :controller => "blog", :only => [:index]
    resource :sessions, :only => [:new, :create, :destroy]
    resource :email, :only => [:show] do
      delete "unsubscribe"
      get "goodbye"
    end
    controller "support" do
      get "about", :action => "about"
      get "press", :action => "press"
    end
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
    resource :session_test, :only => [:new, :show], :controller => "session_test"
    resource :search, :only => [:new, :show], :controller => "search"
    root :to => "home#index"
  end
  
  root :to => "site/previews#index"
end
