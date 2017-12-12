require 'rails_helper'

RSpec.describe "Accounts" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:body) { {} }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/api/accounts'" do
    let(:url) { api_accounts_path(url_params) }
    let(:url_params) { {} }

    describe "GET" do
      let(:method) { :get }

      it_behaves_like "resource_filtering" do
        let(:filter_on_factory) { :account }
      end

      it_behaves_like "authorization"
    end

    describe "POST" do
      let(:method) { :post }

      def assert_create!
        expect(response.code).to eq("201")
      end

      it { assert_create! }
    end
  end

  describe "'/:id'" do
    let(:factory_attributes) { {} }
    let(:account) { create(:account, factory_attributes) }
    let(:url) { api_account_path(account) }

    describe "GET" do
      let(:method) { :get }

      def assert_show!
        expect(response.code).to eq("200")
        expect(response.body).to eq(account.to_json)
      end

      it { assert_show! }
    end

    describe "PATCH" do
      let(:method) { :patch }
      let(:metadata) { { "foo" => "bar" } }
      let(:factory_attributes) { { "metadata" => {"bar" => "baz" }} }
      let(:body) {
        {
          :metadata => metadata,
          :metadata_merge_mode => "replace"
        }
      }

      def assert_update!
        expect(response.code).to eq("204")
        expect(account.reload.metadata).to eq(metadata)
      end

      it { assert_update! }
    end

    describe "DELETE" do
      let(:method) { :delete }

      context "valid request" do
        def assert_destroy!
          expect(response.code).to eq("204")
          expect(Account.find_by_id(account.id)).to eq(nil)
        end

        it { assert_destroy! }
      end

      context "invalid request" do
        let(:user) { create(:user, :account => account) }

        def setup_scenario
          user
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

