require "rails_helper"

RSpec.describe ApplicationController do
  controller do
    def index
      render(html: "foo", layout: true)
    end
  end

  describe "dynamic layout" do
    it "renders the application layout if user is not logged in" do
      get :index

      expect(response).to render_with_layout("application")
    end

    it "renders the dashboard layout if user is logged in" do
      user = create(:user)
      sign_in(user)

      get :index

      expect(response).to render_with_layout("dashboard")
    end
  end
end
