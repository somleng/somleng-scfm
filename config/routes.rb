Rails.application.routes.draw do
  namespace "api", :defaults => { :format => "json" } do
    resources :phone_call_events, :only => [:create], :defaults => { :format => "xml" }

    resources :callouts, :except => [:new, :edit] do
      resources :callout_events, :only => :create
      resources :callout_populations, :only => [:create, :index]
      resource :callout_statistics, :only => :show
    end

    resources :callout_populations, :except => [:new, :edit, :create] do
      resources :callout_population_events, :only => :create
    end
    resources :contacts, :except => [:new, :edit]
  end
end
