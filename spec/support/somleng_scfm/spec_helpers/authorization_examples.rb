RSpec.shared_examples_for "authorization" do |options = {}|
  def assert_unauthorized!
    expect(response.code).to eq("401")
  end

  def assert_authorized!
    expect(response.code).not_to eq("401")
  end

  context "credentials are correct" do
    it { assert_authorized! }
  end

  context "credentials are incorrect" do
    let(:access_token) { nil }
    it { assert_unauthorized! }
  end

  if options[:super_admin_only]
    context "not super admin" do
      let(:account) { create(:access_token).resource_owner }
      it { assert_unauthorized! }
    end
  end
end
