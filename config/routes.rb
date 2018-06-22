Rails.application.routes.draw do
  devise_scope :user do
    get "users/edit" => "devise/registrations#edit", as: "edit_user_registration"
    patch "users" => "devise/registrations#update", as: "user_registration"
  end

  devise_for :users,
             controllers: { invitations: "dashboard/user_invitations" },
             skip: :registrations

  root 'home#index'

  get "/about_us", to: "home#about_us"
  get "/contact", to: "home#contact"

  namespace "dashboard" do
    root to: "callouts#index"
    resources :access_tokens
    resource :account, only: %i[edit update]

    namespace :batch_operation do
      resources :callout_populations, only: %i[edit update]
    end

    resources :batch_operations, only: %i[index show destroy] do
      resources :batch_operation_events, only: :create
      resources :callout_participations, only: :index
      resources :phone_calls, only: :index

      namespace :preview, module: "batch_operation_preview" do
        resources :contacts, only: :index
      end
    end

    resources :contacts do
      resources :callout_participations, only: :index
      resources :phone_calls, only: :index
    end

    resources :callouts do
      namespace :batch_operation do
        resources :callout_populations, only: %i[new create]
      end
      resources :batch_operations, only: %i[index destroy]
      resources :callout_events, only: :create
      resources :callout_participations, only: :index
      resources :phone_calls, only: :index
    end

    resources :callout_participations, only: %i[index show destroy] do
      resources :phone_calls, only: :index
    end

    resources :phone_calls, only: %i[index show destroy] do
      resources :phone_call_events, only: :create
      resources :remote_phone_call_events, only: :index
    end

    resources :remote_phone_call_events, only: %i[index show]
    resources :users, except: %i[new create]
    resources :locales, only: :update
  end

  namespace "api", defaults: { format: "json" } do
    defaults format: :xml do
      resources :remote_phone_call_events, only: :create
    end

    resources :accounts, except: %i[new edit] do
      resources :users, only: :index
      resources :access_tokens, only: :index
    end

    resource :account, only: %i[show update], as: :current_account

    resources :access_tokens

    resources :users, except: %i[new edit] do
      resources :user_events, only: :create
    end

    resources :remote_phone_call_events, only: %i[index show update]

    resources :contacts, except: %i[new edit] do
      resources :callout_participations, only: :index
      resources :callouts, only: :index
      resources :phone_calls, only: :index
      resources :remote_phone_call_events, only: :index
    end

    resource :contact_data, only: :create

    resources :callouts, except: %i[new edit] do
      resources :callout_events, only: :create
      resources :callout_participations, only: %i[index create]
      resources :contacts, only: :index
      resources :phone_calls, only: :index
      resources :remote_phone_call_events, only: :index
      resources :batch_operations, only: %i[create index]
    end

    resources :batch_operations, except: %i[new edit] do
      resources :batch_operation_events, only: :create
      resources :callout_participations, only: :index
      resources :contacts, only: :index
      resources :phone_calls, only: :index

      namespace :preview, module: "batch_operation_preview" do
        resources :callout_participations, only: :index
        resources :contacts, only: :index
        resources :phone_calls, only: :index
      end
    end

    resources :callout_participations, except: %i[new edit create] do
      resources :phone_calls, only: %i[index create]
      resources :remote_phone_call_events, only: :index
    end

    resources :phone_calls, except: %i[new edit create] do
      resources :phone_call_events, only: :create
      resources :remote_phone_call_events, only: :index
    end
  end
end
