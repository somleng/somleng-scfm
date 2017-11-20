require 'rails_helper'

RSpec.describe "'/api/callouts'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:body) { {} }
  let(:metadata) { { "foo" => "bar" } }
  let(:factory_attributes) { {} }
  let(:callout) { create(:callout, factory_attributes) }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/'" do
    let(:url_params) { {} }
    let(:url) { api_callouts_path(url_params) }

    describe "GET" do
      let(:method) { :get }

      it_behaves_like "resource_filtering" do
        let(:filter_on_factory) { :callout }
      end

      it_behaves_like "authorization"
    end

    describe "POST" do
      let(:method) { :post }
      let(:call_flow_logic) { CallFlowLogic::Application.to_s }
      let(:body) { { :metadata => metadata, :call_flow_logic => call_flow_logic } }
      let(:asserted_created_callout) { Callout.last }
      let(:parsed_response) { JSON.parse(response.body) }

      def assert_create!
        expect(response.code).to eq("201")
        expect(parsed_response).to eq(JSON.parse(asserted_created_callout.to_json))
        expect(parsed_response["metadata"]).to eq(metadata)
        expect(parsed_response["call_flow_logic"]).to eq(call_flow_logic)
      end

      it { assert_create! }
    end
  end

  describe "'/:id'" do
    let(:url) { api_callout_path(callout) }

    describe "GET" do
      let(:method) { :get }

      def assert_show!
        expect(response.code).to eq("200")
        expect(response.body).to eq(callout.to_json)
      end

      it { assert_show! }
    end

    describe "PATCH" do
      let(:method) { :patch }
      let(:body) { { :metadata => metadata } }

      def assert_update!
        expect(response.code).to eq("204")
        expect(callout.reload.metadata).to eq(metadata)
      end

      it { assert_update! }
    end

    describe "DELETE" do
      let(:method) { :delete }

      context "valid request" do
        def assert_destroy!
          expect(response.code).to eq("204")
          expect(Callout.find_by_id(callout.id)).to eq(nil)
        end

        it { assert_destroy! }
      end

      context "invalid request" do
        let(:callout_participation) { create(:callout_participation, :callout => callout) }

        def setup_scenario
          callout_participation
          super
        end

        def assert_invalid!
          expect(response.code).to eq("422")
        end

        it { assert_invalid! }
      end
    end
  end

  describe "nested indexes" do
    let(:method) { :get }

    def setup_scenario
      create(:callout)
      callout
      super
    end

    def assert_filtered!
      expect(JSON.parse(response.body)).to eq(JSON.parse([callout].to_json))
    end

    describe "GET '/api/contacts/:contact_id/callouts'" do
      let(:contact) { create(:contact) }

      def setup_scenario
        create(:callout_participation, :contact => contact, :callout => callout)
        super
      end

      let(:url) { api_contact_callouts_path(contact) }
      it { assert_filtered! }
    end
  end
end
