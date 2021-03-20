require "rails_helper"

RSpec.describe Account do
  let(:factory) { :account }

  include_examples "has_metadata"
  include_examples "has_call_flow_logic"

  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:contacts).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:callouts).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:batch_operations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:callout_participations) }
    it { is_expected.to have_many(:phone_calls) }
    it { is_expected.to have_many(:remote_phone_call_events) }
    it { is_expected.to have_many(:access_tokens).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { expect(build(:account)).to be_valid }

    it {
      expect(subject).to validate_inclusion_of(:platform_provider_name).in_array(%w[twilio somleng])
    }

    it {
      expect(
        create(:account, :with_twilio_provider)
      ).to validate_uniqueness_of(:twilio_account_sid).case_insensitive.allow_nil
    }

    it {
      expect(
        create(:account, :with_somleng_provider)
      ).to validate_uniqueness_of(:somleng_account_sid).case_insensitive.allow_nil
    }
  end

  it { is_expected.to strip_attribute(:twilio_account_sid) }
  it { is_expected.to strip_attribute(:somleng_account_sid) }

  it "sets the defaults" do
    account = Account.new

    account.save!

    expect(account.permissions).to be_empty
    expect(account.settings).to eq(
      {
        "from_phone_number" => "1234",
        "phone_call_queue_limit" => 200
      }
    )
  end

  describe "#write_batch_operation_access_token" do
    it "returns an access token which can write batch operations" do
      account = create(:account)
      access_token = create(
        :access_token,
        resource_owner: account,
        permissions: %i[batch_operations_write]
      )

      expect(account.write_batch_operation_access_token).to eq(access_token)
    end
  end

  describe ".find_by_platform_account_sid(account_sid)" do
    it "returns the account" do
      twilio_account = create(:account, twilio_account_sid: generate(:twilio_account_sid))
      expect(
        Account.find_by_platform_account_sid(twilio_account.twilio_account_sid)
      ).to eq(twilio_account)

      somleng_account = create(:account, somleng_account_sid: generate(:somleng_account_sid))
      expect(
        Account.find_by_platform_account_sid(somleng_account.somleng_account_sid)
      ).to eq(somleng_account)

      expect(Account.find_by_platform_account_sid(SecureRandom.uuid)).to eq(nil)
    end
  end
end
