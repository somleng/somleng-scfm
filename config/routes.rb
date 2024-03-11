Rails.application.routes.draw do
  devise_scope :user do
    resource(
      :registration,
      only: %i[edit update],
      controller: "users/registrations",
      as: :user_registration,
      path: "users"
    )
  end

  devise_for :users,
             controllers: { invitations: "users/invitations" },
             skip: :registrations

  get "dashboard", to: "dashboard/callouts#index", as: :user_root
  root to: "dashboard/callouts#index"

  namespace :admin do
    mount(PgHero::Engine, at: "pghero")
    resources :accounts, only: %i[index show]
    resources :callouts, only: %i[index show]
    resources :contacts, only: %i[index show]
    resources :phone_calls, only: %i[index show]
    resources :users, only: %i[index show]

    root to: "accounts#index"
  end

  namespace "dashboard" do
    root to: "callouts#index"
    resources :access_tokens
    resource :account, only: %i[edit update]

    namespace :batch_operation do
      resources :callout_populations, only: %i[edit update]
    end

    resources :batch_operations, only: %i[index show destroy] do
      resources :batch_operation_events, only: :create
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

    resources :phone_calls, only: %i[index show] do
      resources :remote_phone_call_events, only: :index
    end

    resources :remote_phone_call_events, only: %i[index show]
    resources :users, except: %i[new create]
    resources :recordings, only: %i[index show]
    resource :locale, only: :update
  end

  namespace "api", defaults: { format: "json" } do
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
    end

    resources :callout_participations, except: %i[new edit create] do
      resources :phone_calls, only: %i[index]
      resources :remote_phone_call_events, only: :index
    end

    resources :phone_calls, only: %i[index show] do
      resources :remote_phone_call_events, only: :index
    end

    resources :recordings, only: %i[index show]
  end

  namespace :twilio_webhooks, defaults: { format: :xml } do
    resources :recording_status_callbacks, only: :create
    resources :phone_call_events, only: :create
  end
end
