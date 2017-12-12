require 'rails_helper'

RSpec.describe "Users" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:account) { create(:account) }
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
      end

      it_behaves_like "authorization"
    end

    describe "POST" do
      let(:method) { :post }

      let(:body) {
        {
          :email => generate(:email),
          :password => "secret123",
          :account_id => account.id
        }
      }

      def assert_create!
        expect(response.code).to eq("201")
      end

      it { assert_create! }
    end
  end

  describe "'/:id'" do
    let(:factory_attributes) { {} }
    let(:user) { create(:user, factory_attributes) }
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
      let(:factory_attributes) { { "metadata" => {"bar" => "baz" }} }
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
end

