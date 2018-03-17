require 'rails_helper'

RSpec.describe RemotePhoneCallEvent do
  let(:factory) { :remote_phone_call_event }
  include_examples "has_metadata"
  include_examples("has_call_flow_logic")

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:phone_call).validate(true).autosave(true)
    end

    it { assert_associations! }
  end

  describe "validations" do
    context "factory" do
      subject { build(factory) }
      it { is_expected.to be_valid }
    end

    context "persisted" do
      subject { create(factory) }

      def assert_validations!
        is_expected.to validate_presence_of(:call_flow_logic)
        is_expected.to validate_presence_of(:remote_call_id)
        is_expected.to validate_presence_of(:remote_direction)
      end

      it { assert_validations! }
    end
  end

  describe "#setup!" do
    it("should broadcast") {
      assert_broadcasted!(:remote_phone_call_event_initialized) { subject.setup! }
    }
  end
end
