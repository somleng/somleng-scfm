require "rails_helper"

RSpec.describe Dashboard::AccountsController do
  describe "breadcrumbs" do
    render_views

    controller(Dashboard::AccountsController) do
      layout false

      def edit; render_breadcrumbs end
      def update; render_breadcrumbs end

      private

      def render_breadcrumbs
        prepare_breadcrumbs
        render inline: "<%= render 'shared/breadcrumbs' %>"
      end
    end

    it "renders for :edit" do
      routes.draw { get :edit, to: "dashboard/accounts#edit" }

      user_signed_in
      get :edit

      expect(response.body).to have_selector("a", count: 0)
      expect(response.body).to have_text("Accounts")
      expect(response.body).to have_text("Edit")
    end

    it "renders for :patch" do
      routes.draw { patch :update, to: "dashboard/accounts#update" }

      user_signed_in
      patch :update

      expect(response.body).to have_selector("a", count: 0)
      expect(response.body).to have_text("Accounts")
      expect(response.body).to have_text("Edit")
    end
  end
end
