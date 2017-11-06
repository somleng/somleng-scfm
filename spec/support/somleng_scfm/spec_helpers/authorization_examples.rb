RSpec.shared_examples_for "authorization" do
  def assert_unauthorized!
    expect(response.code).to eq("401")
  end

  def assert_authorized!
    expect(response.code).not_to eq("401")
  end

  context "HTTP Basic Auth disabled" do
    let(:http_basic_auth_user) { nil }
    let(:authorization_user) { nil }
    it { assert_authorized! }
  end

  context "HTTP Basic Auth is enabled" do
    context "password is enabled" do
      context "credentials are correct" do
        it { assert_authorized! }
      end

      context "credentials are incorrect" do
        let(:authorization_password) { nil }
        it { assert_unauthorized! }
      end
    end

    context "password is disabled" do
      let(:http_basic_auth_password) { nil }

      context "credentials are correct" do
        it { assert_authorized! }
      end

      context "credentials are incorrect" do
        let(:authorization_user) { "wrong" }
        it { assert_unauthorized! }
      end
    end
  end
end
