require 'rails_helper'

RSpec.describe "'/callout_populations'" do
  include SomlengScfm::SpecHelpers::RequestHelpers
  let(:body) { {} }
  let(:metadata) { { "foo" => "bar" } }
  let(:contact_filter_params) { { "bar" => "baz" } }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/callouts/:callout_id/callout_populations'" do
    let(:callout) { create(:callout) }
    let(:url) { api_callout_callout_populations_path(callout) }

    describe "GET" do
      let(:method) { :get }
      let(:callout_population) { create(:callout_population, :callout => callout) }
      let(:parsed_response) { JSON.parse(response.body) }

      def setup_scenario
        callout_population
        create(:callout_population)
        super
      end

      def assert_index!
        super
        expect(parsed_response).to eq(JSON.parse([callout_population].to_json))
      end

      it { assert_index! }
    end

    describe "POST" do
      let(:method) { :post }
      let(:body) {
        {
          :metadata => metadata,
          :contact_filter_params => contact_filter_params
        }
      }

      context "successful request" do
        let(:asserted_created_callout_population) { callout.callout_populations.last }
        let(:parsed_response) { JSON.parse(response.body) }

        def assert_created!
          expect(response.code).to eq("201")
          expect(parsed_response).to eq(JSON.parse(asserted_created_callout_population.to_json))
          expect(parsed_response["metadata"]).to eq(metadata)
          expect(parsed_response["contact_filter_params"]).to eq(contact_filter_params)
        end

        it { assert_created! }
      end
    end
  end

  describe "'/:id'" do
    let(:callout_population) { create(:callout_population) }
    let(:url) { api_callout_population_path(callout_population) }

    describe "GET" do
      let(:method) { :get }

      def assert_show!
        expect(response.code).to eq("200")
        expect(response.body).to eq(callout_population.to_json)
      end

      it { assert_show! }
    end

    describe "PATCH" do
      let(:method) { :patch }
      let(:body) {
        {
          :metadata => metadata,
          :contact_filter_params => contact_filter_params
        }
      }

      def assert_update!
        expect(response.code).to eq("204")
        expect(callout_population.reload.metadata).to eq(metadata)
        expect(callout_population.contact_filter_params).to eq(contact_filter_params)
      end

      it { assert_update! }
    end

    describe "DELETE" do
      let(:method) { :delete }

      context "valid request" do
        def assert_destroy!
          expect(response.code).to eq("204")
          expect(CalloutPopulation.find_by_id(callout_population.id)).to eq(nil)
        end

        it { assert_destroy! }
      end

      context "invalid request" do
        def setup_scenario
          create(:callout_participation, :callout_population => callout_population)
          super
        end

        def assert_invalid!
          expect(response.code).to eq("422")
        end

        it { assert_invalid! }
      end
    end
  end

  describe "GET '/'" do
    let(:method) { :get }
    let(:url_params) { {} }
    let(:url) { api_callout_populations_path(url_params) }

    it_behaves_like "resource_filtering" do
      let(:filter_on_factory) { :callout_population }
    end

    it_behaves_like "authorization"
  end
end
