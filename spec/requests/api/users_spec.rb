require 'rails_helper'

RSpec.describe "Users" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:account_attributes) { {} }
  let(:account_traits) { {} }
  let(:account) { create(:account, *account_traits.keys, account_attributes) }
  let(:access_token_model) { create(:access_token, :resource_owner => account) }
  let(:factory_attributes) { { :account => account } }
  let(:user) { create(:user, factory_attributes) }

  let(:body) { {} }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/api/users'"do
    let(:url) { api_users_path(url_params) }
    let(:url_params) { {} }

    describe "GET" do
      let(:method) { :get }

      it_behaves_like "resource_filtering" do
        let(:filter_on_factory) { :user }
        let(:filter_factory_attributes) { { :account => account } }
      end

      it_behaves_like "authorization"
    end

    describe "POST" do
      let(:method) { :post }
      let(:created_user) { User.last }

      let(:body) {
        {
          :email => generate(:email),
          :password => "secret123"
        }
      }

      def assert_create!
        expect(response.code).to eq("201")
        expect(created_user.account).to eq(asserted_account)
      end

      context "super admin account" do
        let(:account_traits) { super().merge(:super_admin => nil) }
        let(:another_account) { create(:account) }
        let(:asserted_account) { another_account }
        let(:body) { super().merge(:account_id => another_account.id) }

        it { assert_create! }
      end

      context "normal account" do
        let(:asserted_account) { account }
        it { assert_create! }
      end
    end
  end

  describe "'/:id'" do
    let(:url) { api_user_path(user) }

    describe "GET" do
      let(:method) { :get }

      def assert_show!
        expect(response.code).to eq("200")
        expect(response.body).to eq(user.to_json)
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
        expect(user.reload.metadata).to eq(metadata)
      end

      it { assert_update! }
    end

    describe "DELETE" do
      let(:method) { :delete }

      context "valid request" do
        def assert_destroy!
          expect(response.code).to eq("204")
          expect(User.find_by_id(user.id)).to eq(nil)
        end

        it { assert_destroy! }
      end
    end
  end

  describe "nested indexes" do
    let(:account_traits) { super().merge(:super_admin => nil) }
    let(:method) { :get }
    let(:another_account) { create(:account) }
    let(:factory_attributes) { super().merge(:account => another_account) }

    def setup_scenario
      create(:user, :account => account)
      user
      super
    end

    def assert_filtered!
      expect(JSON.parse(response.body)).to eq(JSON.parse([user].to_json))
    end

    describe "GET '/api/accounts/:account_id/users'" do
      let(:url) { api_account_users_path(another_account) }
      it { assert_filtered! }
    end
  end
end

