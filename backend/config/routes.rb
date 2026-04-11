Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users,
        path: "",
        path_names: {
          sign_in: "users/sign_in",
          sign_out: "users/sign_out",
          registration: "users/sign_up"
        },
        controllers: {
          sessions: "api/v1/users/sessions",
          registrations: "api/v1/users/registrations"
        }

      resources :recruitments, only: [:index, :show, :edit, :create, :update, :destroy] do
        resources :participations, only: [:create]
      end
      resource :profile, only: [:show, :update, :create]
      resource :my_page, only: [:show]
      resources :participations, only: [:update]
      resources :users, only: [:show]
      resources :notifications, only: [:index, :update] do
        collection do
          patch :mark_all_read
        end
      end
      resources :chats, only: [:index, :show] do
        resources :messages, only: [:index, :create]
      end
    end
  end

  get "health", to: proc { [200, {}, [{ status: "ok" }.to_json]] }
end