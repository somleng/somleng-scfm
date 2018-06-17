require "rails_helper"

RSpec.describe Dashboard::BaseController do
  it { is_expected.to be_a(Breadcrumbs) }

  describe "top level breadcrumbs" do
    render_views

    controller(Dashboard::CalloutsController) do
      layout false

      def index; render_breadcrumbs end
      def show; render_breadcrumbs end
      def new; render_breadcrumbs end
      def create; render_breadcrumbs end
      def edit; render_breadcrumbs end
      def update; render_breadcrumbs end

      private

      def render_breadcrumbs
        prepare_breadcrumbs
        render inline: "<%= render 'shared/breadcrumbs' %>"
      end
    end

    it "renders for :index" do
      user_signed_in
      get :index

      expect(response.body).to have_selector("a", count: 0)
      expect(response.body).to have_text("Callouts")
    end

    it "renders for :show" do
      resource = build_stubbed(:callout)
      allow(controller).to receive(:resource).and_return(resource)

      user_signed_in
      get :show, params: { id: resource.id }

      expect(response.body).to have_selector("a", count: 1)
      expect(response.body).to have_link("Callouts", href: dashboard_callouts_path)
      expect(response.body).to have_text(resource.id)
    end

    it "renders for :edit" do
      resource = build_stubbed(:callout)
      allow(controller).to receive(:resource).and_return(resource)

      user_signed_in
      get :edit, params: { id: resource.id }

      expect(response.body).to have_selector("a", count: 2)
      expect(response.body).to have_link("Callouts", href: dashboard_callouts_path)
      expect(response.body).to have_link(resource.id, href: dashboard_callout_path(resource))
      expect(response.body).to have_text("Edit")
    end

    it "renders for :update" do
      resource = build_stubbed(:callout)
      allow(controller).to receive(:resource).and_return(resource)

      user_signed_in
      patch :update, params: { id: resource.id }

      expect(response.body).to have_selector("a", count: 2)
      expect(response.body).to have_link("Callouts", href: dashboard_callouts_path)
      expect(response.body).to have_link(resource.id, href: dashboard_callout_path(resource))
      expect(response.body).to have_text("Edit")
    end

    it "renders for :new" do
      user_signed_in
      get :new

      expect(response.body).to have_selector("a", count: 1)
      expect(response.body).to have_link("Callouts", href: dashboard_callouts_path)
      expect(response.body).to have_text("New")
    end

    it "renders for :create" do
      user_signed_in
      post :create

      expect(response.body).to have_selector("a", count: 1)
      expect(response.body).to have_link("Callouts", href: dashboard_callouts_path)
      expect(response.body).to have_text("New")
    end
  end

  describe "nested level breadcrumbs" do
    render_views

    controller(Dashboard::CalloutParticipationsController) do
      layout false

      def index; render_breadcrumbs end

      private

      def render_breadcrumbs
        prepare_breadcrumbs
        render inline: "<%= render 'shared/breadcrumbs' %>"
      end
    end

    it "renders for :index" do
      parent_resource = build_stubbed(:callout)
      allow(controller).to receive(:parent_resource).and_return(parent_resource)
      allow_any_instance_of(ActionController::TestRequest).to receive(:path).and_return(dashboard_callout_callout_participations_path(parent_resource))

      user_signed_in
      get :index, params: { callout_id: parent_resource.id }

      expect(response.body).to have_selector("a", count: 2)
      expect(response.body).to have_link("Callouts", href: dashboard_callouts_path)
      expect(response.body).to have_link(parent_resource.id, href: dashboard_callout_path(parent_resource))
      expect(response.body).to have_text("Callout participations")
    end
  end
end
