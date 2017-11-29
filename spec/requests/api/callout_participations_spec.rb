require 'rails_helper'

RSpec.describe "Callout Participations" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:callout) { create(:callout) }
  let(:body) { {} }
  let(:factory_attributes) { {} }
  let(:callout_participation) { create(:callout_participation, factory_attributes) }
  let(:execute_request_before) { true }

  def execute_request
    do_request(method, url, body)
  end

  def setup_scenario
    super
    execute_request if execute_request_before
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

    describe "GET '/api/batch_operation/:batch_operation_id/callout_participations'" do
      let(:url) { api_batch_operation_callout_participations_path(batch_operation) }
      let(:batch_operation) { create(batch_operation_factory) }

      context "BatchOperation::CalloutPopulation" do
        let(:batch_operation_factory) { :callout_population }
        let(:factory_attributes) { { :callout_population => batch_operation } }
        it { assert_filtered! }
      end

      context "BatchOperation::PhoneCallCreate" do
        let(:batch_operation_factory) { :phone_call_create_batch_operation }
        let(:phone_call) {
          build(
            :phone_call,
            :create_batch_operation => batch_operation
          )
        }

        let(:factory_attributes) { { :phone_calls => [phone_call] } }

        it { assert_filtered! }
      end
    end

    describe "GET '/api/batch_operations/:batch_operation_id/preview/callout_participations'" do
      let(:url) { api_batch_operation_preview_callout_participations_path(batch_operation) }
      let(:factory_attributes) { { :metadata => {"foo" => "bar", "bar" => "foo"} } }
      let(:batch_operation) {
        create(
          :phone_call_create_batch_operation,
          :callout_participation_filter_params => factory_attributes.slice(:metadata)
        )
      }

      context "successful request" do
        it { assert_filtered! }
      end

      context "invalid request" do
        let(:execute_request_before) { false }
        let(:batch_operation) { create(:callout_population) }
        it {expect { execute_request }.to raise_error(ActiveRecord::RecordNotFound) }
      end
    end
  end

  describe "POST '/api/callout/:callout_id/callout_participations'" do
    let(:url) { api_callout_callout_participations_path(callout) }
    let(:method) { :post }

    context "invalid request" do
      def assert_invalid!
        expect(response.code).to eq("422")
      end

      it { assert_invalid! }
    end

    context "valid request" do
      let(:metadata) { { "foo" => "bar" } }
      let(:call_flow_logic) { CallFlowLogic::Application.to_s }
      let(:contact) { create(:contact) }
      let(:msisdn) { generate(:somali_msisdn) }
      let(:parsed_response) { JSON.parse(response.body) }

      let(:body) {
        {
          :metadata => metadata,
          :contact_id => contact.id,
          :call_flow_logic => call_flow_logic,
          :msisdn => msisdn
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
        expect(parsed_response["msisdn"]).to eq("+#{msisdn}")
        expect(created_callout_participation.callout).to eq(callout)
        expect(created_callout_participation.contact).to eq(contact)
        expect(created_callout_participation.metadata).to eq(metadata)
        expect(created_callout_participation.call_flow_logic).to eq(call_flow_logic)
      end

      it { assert_created! }
    end
  end

  describe "'/callout_participations/:id'" do
    let(:url) { api_callout_participation_path(callout_participation) }

    describe "GET" do
      let(:method) { :get }

      def assert_show!
        expect(response.code).to eq("200")
        expect(response.body).to eq(callout_participation.to_json)
      end

      it { assert_show! }
    end

    describe "PATCH" do
      let(:factory_attributes) { { "metadata" => {"bar" => "baz" }} }
      let(:method) { :patch }
      let(:contact) { create(:contact) }
      let(:call_flow_logic) { CallFlowLogic::Application.to_s }
      let(:metadata) { {"foo" => "bar"} }
      let(:msisdn) { generate(:somali_msisdn) }
      let(:body) {
        {
          :metadata_merge_mode => "replace",
          :metadata => metadata,
          :contact_id => contact.id,
          :call_flow_logic => call_flow_logic,
          :msisdn => msisdn
        }
      }

      def assert_update!
        expect(response.code).to eq("204")
        expect(callout_participation.reload.metadata).to eq(metadata)
        expect(callout_participation.call_flow_logic).to eq(call_flow_logic)
        expect(callout_participation.contact).not_to eq(contact)
        expect(callout_participation.msisdn).to eq("+#{msisdn}")
      end

      it { assert_update! }
    end

    describe "DELETE" do
      let(:method) { :delete }

      def assert_destroy!
        expect(response.code).to eq("204")
        expect(CalloutParticipation.find_by_id(callout_participation.id)).to eq(nil)
      end

      it { assert_destroy! }
    end
  end
end
