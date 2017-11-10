require 'rails_helper'

RSpec.describe "Contacts" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:body) { {} }
  let(:metadata) { { "foo" => "bar" } }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/api/callout_population/:callout_population_id'" do
    let(:callout_population_factory_options) { {} }
    let(:callout_population) { create(:callout_population, callout_population_factory_options) }
    let(:method) { :get }
    let(:asserted_parsed_body) { JSON.parse([contact].to_json) }
    let(:parsed_body) { JSON.parse(response.body) }

    def assert_index!
      super
      expect(parsed_body).to eq(asserted_parsed_body)
    end

    describe "GET '/contacts'" do
      let(:url) { api_callout_population_contacts_path(callout_population) }
      let(:contact) { create(:contact) }

      def setup_scenario
        create(:contact)
        create(
          :callout_participation,
          :callout_population => callout_population,
          :contact => contact
        )
        super
      end

      it { assert_index! }
    end

    describe  "GET '/preview/contacts'" do
      let(:url) { api_callout_population_preview_contacts_path(callout_population) }
      let(:contact_metadata) {
        {
          "province" => "Phnom Penh",
          "commune" => "Chhbar Ambov"
        }
      }

      let(:contact) { create(:contact, :metadata => contact_metadata) }
      let(:callout_population_factory_options) {
        {
          :contact_filter_params => {
            :metadata => {
              "province" => "Phnom Penh"
            }
          }
        }
      }

      def setup_scenario
        contact
        create(:contact)
        super
      end

      it { assert_index! }
    end
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
end
