Spot::Application.routes.draw do
  scope :module => "site" do
    resources :previews, :only => [:index, :create] do
      get "share"
    end
    resources :blog, :controller => "blog", :only => [:index]
    controller "support" do
      get "about", :action => "about"
    end
  end
  
  root :to => "site/previews#index"
end
