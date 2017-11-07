require 'rails_helper'

RSpec.describe "'/api/contacts'" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:body) { {} }
  let(:metadata) { { "foo" => "bar" } }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/'" do
    let(:url_params) { {} }
    let(:url) { api_contacts_path(url_params) }

    describe "GET" do
      let(:method) { :get }
      it_behaves_like "authorization"
      it_behaves_like "index_filtering" do
        let(:filter_on_factory) { :contact }
      end
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

  describe "'/:id'" do
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

    describe "PUT" do
      let(:method) { :put }
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
