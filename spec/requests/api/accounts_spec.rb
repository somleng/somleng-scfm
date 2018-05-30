require "rails_helper"

RSpec.describe "Accounts" do
  include SomlengScfm::SpecHelpers::RequestHelpers

  let(:body) { {} }
  let(:factory_attributes) { {} }
  let(:factory_traits) { { super_admin: nil } }
  let(:account) { create(:account, *factory_traits.keys, factory_attributes) }
  let(:access_token_model) { create(:access_token, resource_owner: account) }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "'/api/accounts'" do
    let(:url) { api_accounts_path(url_params) }
    let(:url_params) { {} }

    describe "GET" do
      let(:method) { :get }

      it_behaves_like("resource_filtering", filter_by_account: false) do
        let(:filter_on_factory) { :account }
        let(:filter_factory_attributes) { {} }
      end

      it_behaves_like("authorization", super_admin_only: true)
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
    let(:resource_account) { account }
    let(:url) { api_account_path(resource_account) }

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
      let(:factory_attributes) { super().merge("metadata" => { "bar" => "baz" }) }
      let(:twilio_account_sid) { generate(:twilio_account_sid) }
      let(:twilio_auth_token) { generate(:auth_token) }
      let(:somleng_account_sid) { generate(:somleng_account_sid) }
      let(:somleng_auth_token) { generate(:auth_token) }
      let(:settings) { { platform_provider_name: "somleng" } }

      let(:body) do
        {
          metadata: metadata,
          metadata_merge_mode: "replace",
          twilio_account_sid: twilio_account_sid,
          somleng_account_sid: somleng_account_sid,
          twilio_auth_token: twilio_auth_token,
          somleng_auth_token: somleng_auth_token,
          call_flow_logic: CallFlowLogic::HelloWorld.to_s,
          settings: settings
        }
      end

      def assert_update!
        expect(response.code).to eq("204")
        expect(account.reload.metadata).to eq(metadata)
        expect(account.twilio_account_sid).to eq(twilio_account_sid)
        expect(account.twilio_auth_token).to eq(twilio_auth_token)
        expect(account.somleng_account_sid).to eq(somleng_account_sid)
        expect(account.somleng_auth_token).to eq(somleng_auth_token)
        expect(account.platform_provider_name).to eq("somleng")
        expect(account.call_flow_logic).to eq("CallFlowLogic::HelloWorld")
      end

      it { assert_update! }
    end

    describe "DELETE" do
      let(:method) { :delete }
      let(:resource_account) { create(:account) }

      context "valid request" do
        def assert_destroy!
          expect(response.code).to eq("204")
          expect(Account.find_by_id(resource_account.id)).to eq(nil)
        end

        it { assert_destroy! }
      end

      context "invalid request" do
        let(:user) { create(:user, account: resource_account) }

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
