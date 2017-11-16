Rails.application.routes.draw do
  namespace "api", :defaults => { :format => "json" } do

    defaults :format => :xml do
      resources :remote_phone_call_events, :only => :create
    end

    resources :remote_phone_call_events, :only => [:index, :show, :update]

    resources :contacts, :except => [:new, :edit] do
      resources :callout_participations, :only => :index
      resources :phone_calls, :only => :index
    end

    resources :callouts, :except => [:new, :edit] do
      resources :callout_events, :only => :create
      resources :callout_participations, :only => [:index, :create]
      resources :contacts, :only => :index
      resources :phone_calls, :only => :index
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
    end

    resources :phone_calls, :except => [:new, :edit, :create] do
      resources :phone_call_events, :only => :create
    end
  end
end
