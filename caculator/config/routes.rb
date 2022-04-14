Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :order, only:[:index] do
    collection do
      #get  :sold
      #post :on_offer
    end
  end

  resources :user, only:[:index] do
    collection do
      post  :login
      get   :logout
    end
  end

  resources :promotion do
    collection do
      post  :check_promotion
    end
  end
end
