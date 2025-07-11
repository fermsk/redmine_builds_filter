Rails.application.routes.draw do
  resources :builds, only: [:index, :show]
  
  resources :projects do
    resources :builds do
      collection do
        get :auto_complete
      end
    end
  end
end