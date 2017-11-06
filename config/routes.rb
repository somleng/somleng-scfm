Rails.application.routes.draw do
  namespace "api", :defaults => { :format => "json" } do
    resources :phone_call_events, :only => [:create], :defaults => { :format => "xml" }
    resources :callouts, :only => [:index, :show] do
      resources :callout_events, :only => :create
    end
  end
end
