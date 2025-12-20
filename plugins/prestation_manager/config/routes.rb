# plugins/prestation_manager/config/routes.rb
resources :projects do
  resources :prestataires, only: [:index] do
    member do
      get :edit_inline
      patch :update_inline
      get :cancel_inline
    end
  end
end
