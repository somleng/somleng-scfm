require 'rails_helper'

RSpec.describe "Callout Participations" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:callout) { create(:callout) }
  let(:body) { {} }
  let(:factory_attributes) { {} }
  let(:callout_participation) { create(:callout_participation, factory_attributes) }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/callout_participations'" do
    let(:url_params) { {} }
    let(:url) { api_callout_participations_path(url_params) }

    describe "GET" do
      let(:method) { :get }

      it_behaves_like "resource_filtering" do
        let(:filter_on_factory) { :callout_participation }
      end

      it_behaves_like "authorization"
    end
  end

  describe "nested indexes" do
    let(:method) { :get }

    def assert_filtered!
      assert_index!
      expect(JSON.parse(response.body)).to eq(JSON.parse([callout_participation].to_json))
    end

    def setup_filtering_scenario
      callout_participation
      create(:callout_participation)
    end

    def setup_scenario
      setup_filtering_scenario
      super
    end

    describe "GET '/api/callout/:callout_id/callout_participations'" do
      let(:url) { api_callout_callout_participations_path(callout) }
      let(:factory_attributes) { { :callout => callout } }
      it { assert_filtered! }
    end

    describe "GET '/api/contact/:contact_id/callout_participations'" do
      let(:contact) { create(:contact) }
      let(:url) { api_contact_callout_participations_path(contact) }
      let(:factory_attributes) { { :contact => contact } }
      it { assert_filtered! }
    end

    describe "GET '/api/callout_population/:callout_population_id/callout_participations'" do
      let(:callout_population) { create(:callout_population) }
      let(:url) { api_callout_population_callout_participations_path(callout_population) }
      let(:factory_attributes) { { :callout_population => callout_population } }
      it { assert_filtered! }
    end
  end

  describe "'/api/callout/:callout_id/callout_participations'" do
    let(:url) { api_callout_callout_participations_path(callout) }

    describe "POST" do
      let(:method) { :post }

      context "invalid request" do
        def assert_invalid!
          expect(response.code).to eq("422")
        end

        it { assert_invalid! }
      end

      context "valid request" do
        let(:metadata) { { "foo" => "bar" } }
        let(:contact) { create(:contact) }

        let(:body) {
          {
            :metadata => metadata,
            :contact_id => contact.id
          }
        }

        let(:created_callout_participation) { callout.callout_participations.last }

        def setup_scenario
          contact
          super
        end

        def assert_created!
          expect(response.code).to eq("201")
          expect(response.headers["Location"]).to eq(api_callout_participation_path(created_callout_participation))
          expect(created_callout_participation.callout).to eq(callout)
          expect(created_callout_participation.contact).to eq(contact)
          expect(created_callout_participation.metadata).to eq(metadata)
        end

        it { assert_created! }
      end
    end
  end
end
