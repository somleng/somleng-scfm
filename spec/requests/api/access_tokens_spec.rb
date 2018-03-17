require 'rails_helper'

RSpec.describe "Access Tokens" do
  include SomlengScfm::SpecHelpers::RequestHelpers
  let(:account_traits) { {} }
  let(:account_attributes) { {} }
  let(:account) { create(:account, *account_traits.keys, account_attributes) }
  let(:factory_attributes) { { :resource_owner => account } }
  let(:access_token_model) { create(:access_token, factory_attributes) }

  let(:body) { {} }
  let(:metadata) { { "foo" => "bar" } }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/api/access_tokens'" do
    let(:url_params) { {} }
    let(:url) { api_access_tokens_path(url_params) }

    describe "GET" do
      let(:method) { :get }

      it_behaves_like "resource_filtering" do
        let(:filter_on_factory) { :access_token }
        let(:filter_factory_attributes) { factory_attributes }
        let(:filtered_resource) { access_token_model }
      end

      it_behaves_like "authorization"
    end

    describe "POST" do
      let(:method) { :post }
      let(:created_access_token) { AccessToken.last }

      let(:body) {
        {
          :email => generate(:email),
          :password => "secret123"
        }
      }

      def assert_create!
        expect(response.code).to eq("201")
        expect(created_access_token.resource_owner).to eq(asserted_account)
        expect(created_access_token.created_by).to eq(asserted_created_by)
      end

      context "super admin account" do
        let(:account_traits) { super().merge(:super_admin => nil) }
        let(:another_account) { create(:account) }
        let(:asserted_account) { another_account }
        let(:asserted_created_by) { account }
        let(:body) { super().merge(:account_id => another_account.id) }

        it { assert_create! }
      end

      context "normal account" do
        let(:asserted_account) { account }
        let(:asserted_created_by) { account }
        it { assert_create! }
      end
    end
  end

  describe "'/:id'" do
    let(:url) { api_access_token_path(access_token_model) }

    describe "GET" do
      let(:method) { :get }

      def assert_show!
        expect(response.code).to eq("200")
        expect(response.body).to eq(access_token_model.to_json)
      end

      it { assert_show! }
    end

    describe "PATCH" do
      let(:method) { :patch }
      let(:metadata) { { "foo" => "bar" } }
      let(:factory_attributes) { super().merge("metadata" => {"bar" => "baz" }) }
      let(:body) {
        {
          :metadata => metadata,
          :metadata_merge_mode => "replace"
        }
      }

      def assert_update!
        expect(response.code).to eq("204")
        expect(access_token_model.reload.metadata).to eq(metadata)
      end

      it { assert_update! }
    end

    describe "DELETE" do
      let(:method) { :delete }

      context "valid request" do
        def assert_destroy!
          expect(response.code).to eq("204")
          expect(AccessToken.find_by_id(access_token_model.id)).to eq(nil)
        end

        it { assert_destroy! }
      end

      context "invalid request" do
        let(:factory_attributes) { { :created_by => create(:account) } }

        def assert_invalid!
          expect(response.code).to eq("422")
        end

        it { assert_invalid! }
      end
    end
  end

  describe "nested indexes" do
    let(:account_traits) { super().merge(:super_admin => nil) }
    let(:method) { :get }
    let(:another_account) { create(:account) }
    let(:factory_attributes) { super().merge(:resource_owner => another_account) }

    def setup_scenario
      create(:access_token, :resource_owner => account)
      super
    end

    def assert_filtered!
      expect(JSON.parse(response.body)).to eq(JSON.parse([access_token_model].to_json))
    end

    describe "GET '/api/accounts/:account_id/access_tokens'" do
      let(:url) { api_account_access_tokens_path(another_account) }
      it { assert_filtered! }
    end
  end
end
