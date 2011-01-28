Spot::Application.routes.draw do
  scope :module => "site" do
    resource :preview, :only => [:index, :create] do
      get "share"
    end
    resources :blog, :controller => "blog", :only => [:index]
  end
  root :to => "site/previews#index"
end
