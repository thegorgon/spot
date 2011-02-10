Spot::Application.routes.draw do
  scope :module => "site", :constraints => {:subdomain => /www|m/} do
    resources :previews, :only => [:index, :create] do
      get "share"
    end
    resources :blog, :controller => "blog", :only => [:index]
    controller "support" do
      get "about", :action => "about"
    end
  end
  
  scope :module => "api", :constraints => {:subdomain => /api\d*/} do
    resources :places, :only => [:index] do
      collection do 
        get "search"
      end
    end
  end
  
  namespace "admin" do
    resources :places do
      member do
        get "images" 
      end
    end
    root :to => "home#index"
  end
  
  root :to => "site/previews#index"
end
