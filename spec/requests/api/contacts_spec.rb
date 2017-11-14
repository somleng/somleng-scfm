require 'rails_helper'

RSpec.describe "Contacts" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:body) { {} }
  let(:metadata) { { "foo" => "bar" } }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/api/contacts'" do
    let(:url_params) { {} }
    let(:url) { api_contacts_path(url_params) }

    describe "GET" do
      let(:method) { :get }

      it_behaves_like "resource_filtering" do
        let(:filter_on_factory) { :contact }
      end

      it_behaves_like "authorization"
    end

    describe "POST" do
      let(:method) { :post }
      let(:msisdn) { generate(:somali_msisdn) }

      let(:body) {
        {
          :metadata => metadata,
          :msisdn => msisdn
        }
      }

      context "valid request" do
        let(:asserted_created_contact) { Contact.last }
        let(:parsed_response) { JSON.parse(response.body) }

        def assert_create!
          expect(response.code).to eq("201")
          expect(parsed_response).to eq(JSON.parse(asserted_created_contact.to_json))
          expect(parsed_response["metadata"]).to eq(metadata)
        end

        it { assert_create! }
      end

      context "invalid request" do
        let(:msisdn) { nil }

        def assert_invalid!
          expect(response.code).to eq("422")
        end

        it { assert_invalid! }
      end
    end
  end

  describe "'/api/contacts/:id'" do
    let(:contact) { create(:contact) }
    let(:url) { api_contact_path(contact) }

    describe "GET" do
      let(:method) { :get }

      def assert_show!
        expect(response.code).to eq("200")
        expect(response.body).to eq(contact.to_json)
      end

      it { assert_show! }
    end

    describe "PATCH" do
      let(:method) { :patch }
      let(:body) { { :metadata => metadata } }

      def assert_update!
        expect(response.code).to eq("204")
        expect(contact.reload.metadata).to eq(metadata)
      end

      it { assert_update! }
    end

    describe "DELETE" do
      let(:method) { :delete }

      context "valid request" do
        def assert_destroy!
          expect(response.code).to eq("204")
          expect(Contact.find_by_id(contact.id)).to eq(nil)
        end

        it { assert_destroy! }
      end

      context "invalid request" do
        let(:phone_call) { create(:phone_call, :contact => contact) }

        def setup_scenario
          phone_call
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
    let(:contact_factory_attributes) { {} }
    let(:contact) { create(:contact, contact_factory_attributes) }

    def callout_participation_factory_attributes
      {:contact => contact}
    end

    let(:callout_participation) {
      create(:callout_participation, callout_participation_factory_attributes)
    }

    def setup_scenario
      contact
      create(:contact)
      super
    end

    def assert_filtered!
      assert_index!
      expect(JSON.parse(response.body)).to eq(JSON.parse([contact].to_json))
    end

    describe "GET '/api/callouts/:callout_id/contacts'" do
      let(:callout) { create(:callout) }
      let(:url) { api_callout_contacts_path(callout) }

      def callout_participation_factory_attributes
        super.merge(:callout => callout)
      end

      def setup_scenario
        callout_participation
        super
      end

      it { assert_filtered! }
    end

    describe "'/api/batch_operations/:batch_operation_id'" do
      let(:batch_operation_factory_attributes) { {} }
      let(:batch_operation) {
        create(batch_operation_factory, batch_operation_factory_attributes)
      }

      describe "GET '/contacts'" do
        let(:url) { api_batch_operation_contacts_path(batch_operation) }

        context "BatchOperation::CalloutPopulation" do
          let(:batch_operation_factory) { :callout_population }

          def callout_participation_factory_attributes
            super.merge(:callout_population => batch_operation)
          end

          def setup_scenario
            callout_participation
            super
          end

          it { assert_filtered! }
        end

        context "BatchOperation::PhoneCallCreate" do
          let(:batch_operation_factory) { :phone_call_create_batch_operation }

          def setup_scenario
            create(
              :phone_call,
              :callout_participation => callout_participation,
              :create_batch_operation => batch_operation
            )
            super
          end

          it { assert_filtered! }
        end
      end

      describe  "GET '/preview/contacts'" do
        let(:url) { api_batch_operation_preview_contacts_path(batch_operation) }

        context "BatchOperation::CalloutPopulation" do
          let(:batch_operation_factory) { :callout_population }
          let(:contact_factory_attributes) { { :metadata => {"foo" => "bar", "bar" => "foo"} } }
          let(:contact_filter_params) { contact_factory_attributes.slice(:metadata) }
          let(:batch_operation_factory_attributes) { { :contact_filter_params => contact_filter_params } }

          it { assert_filtered! }
        end

        context "BatchOperation::PhoneCallCreate" do
          let(:batch_operation_factory) { :phone_call_create_batch_operation }

          def setup_scenario
            callout_participation
            super
          end

          it { assert_filtered! }
        end
      end
    end
  end
end
