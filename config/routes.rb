Spot::Application.routes.draw do
  scope :module => "site" do
    resource :preview do
      get "share"
    end
  end
  root :to => "site/previews#index"
end
