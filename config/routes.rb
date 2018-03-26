Rails.application.routes.draw do
  devise_scope :user do
    get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
    put 'users' => 'devise/registrations#update', as: 'user_registration'
  end

  devise_for :users,
    controllers: { invitations: 'dashboard/user_invitations' },
    skip: :registrations

  root to: redirect('dashboard')

  namespace 'dashboard' do
    root to: 'callouts#index'
    resources :users, only: [:index, :show, :edit, :update, :destroy]
    resources :access_tokens, only: :index
    resources :contacts
    resources :callouts do
      resources :callout_events, :only => :create
    end
  end

  namespace "api", :defaults => { :format => "json" } do
    defaults :format => :xml do
      resources :remote_phone_call_events, :only => :create
    end

    resources :accounts, :except => [:new, :edit] do
      resources :users, :only => :index
      resources :access_tokens, :only => :index
    end

    resource :account, :only => [:show, :update], :as => :current_account

    resources :access_tokens

    resources :users, :except => [:new, :edit] do
      resources :user_events, :only => :create
    end

    resources :remote_phone_call_events, :only => [:index, :show, :update]

    resources :contacts, :except => [:new, :edit] do
      resources :callout_participations, :only => :index
      resources :callouts, :only => :index
      resources :phone_calls, :only => :index
      resources :remote_phone_call_events, :only => :index
    end

    resources :callouts, :except => [:new, :edit] do
      resources :callout_events, :only => :create
      resources :callout_participations, :only => [:index, :create]
      resources :contacts, :only => :index
      resources :phone_calls, :only => :index
      resources :remote_phone_call_events, :only => :index
      resources :batch_operations, :only => [:create, :index]
    end

    resources :batch_operations, :except => [:new, :edit] do
      resources :batch_operation_events, :only => :create
      resources :callout_participations, :only => :index
      resources :contacts, :only => :index
      resources :phone_calls, :only => :index

      namespace :preview, :module => "batch_operation_preview" do
        resources :callout_participations, :only => :index
        resources :contacts, :only => :index
        resources :phone_calls, :only => :index
      end
    end

    resources :callout_participations, :except => [:new, :edit, :create] do
      resources :phone_calls, :only => [:index, :create]
      resources :remote_phone_call_events, :only => :index
    end

    resources :phone_calls, :except => [:new, :edit, :create] do
      resources :phone_call_events, :only => :create
      resources :remote_phone_call_events, :only => :index
    end
  end
end
