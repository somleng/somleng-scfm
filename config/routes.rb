Rails.application.routes.draw do
  namespace "api", :defaults => { :format => "json" } do
    resources :remote_phone_call_events, :only => [:create], :defaults => { :format => "xml" }

    resources :contacts, :except => [:new, :edit] do
      resources :callout_participations, :only => :index
    end

    resources :callouts, :except => [:new, :edit] do
      resources :callout_events, :only => :create
      resources :callout_populations, :only => [:create, :index]
      resources :callout_participations, :only => [:index, :create]
      resources :contacts, :only => :index
      resource :callout_statistics, :only => :show
    end

    resources :callout_populations, :except => [:new, :edit, :create] do
      resources :callout_population_events, :only => :create
      resources :contacts, :only => :index

      namespace :preview, :module => "callout_population_previews" do
        resources :contacts, :only => :index
      end

      resources :callout_participations, :only => :index
    end

    resources :callout_participations, :except => [:new, :edit, :create]
  end
end
