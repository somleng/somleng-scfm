require 'rails_helper'

RSpec.describe "Account" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:body) { {} }
  let(:factory_attributes) { {} }
  let(:factory_traits) { {:with_access_token => nil} }
  let(:account) { create(:account, *factory_traits.keys, factory_attributes) }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/api/account'" do
    let(:url) { api_current_account_path }

    describe "GET" do
      let(:method) { :get }
      it_behaves_like("authorization")

      def assert_show!
        expect(response.code).to eq("200")
      end

      it { assert_show! }
    end

    describe "PATCH" do
      let(:method) { :patch }
      let(:metadata) { { "foo" => "bar" } }
      let(:factory_attributes) { super().merge("metadata" => {"bar" => "baz" }) }

      def assert_update!
        expect(response.code).to eq("204")
      end

      it { assert_update! }
    end
  end
end

