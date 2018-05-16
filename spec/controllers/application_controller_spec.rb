require "rails_helper"

RSpec.describe ApplicationController do
  controller do
    def index
      render html: "<p>test view</p>".html_safe, layout: true
    end
  end

  describe "dynamic layout" do
    it "should render application layout if user not login" do
      get :index

      expect(response).to render_with_layout("application")
    end

    it "should render dashboard layout if user logged in" do
      user = create(:user)
      sign_in(user)

      get :index

      expect(response).to render_with_layout("dashboard")
    end
  end
end
