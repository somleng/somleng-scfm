Rails.application.routes.draw do
  namespace "api", :defaults => { :format => "json" } do
    resources :phone_call_events, :only => [:create], :defaults => { :format => "xml" }
  end
end
