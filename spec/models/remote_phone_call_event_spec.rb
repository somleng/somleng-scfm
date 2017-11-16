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

  describe "defaults" do
    let(:factory_attributes) { {} }
    subject { build(factory, factory_attributes) }

    def setup_scenario
      super
      subject.valid?
    end

    def assert_defaults!
      expect(subject.errors).to be_empty
      expect(subject.remote_call_id).to eq(subject.details["CallSid"])
      expect(subject.remote_direction).to eq(subject.details["Direction"])
      expect(subject.call_flow_logic).to eq(described_class::DEFAULT_CALL_FLOW_LOGIC.to_s)
      expect(subject.phone_call.call_flow_logic).to eq(subject.call_flow_logic)
    end

    context "phone call does not exist" do
      def assert_defaults!
        super
        phone_call = subject.phone_call
        expect(phone_call).to be_present
        expect(phone_call.remote_call_id).to eq(subject.remote_call_id)
        expect(phone_call.remote_direction).to eq(subject.remote_direction)
        expect(phone_call.msisdn).to eq(PhonyRails.normalize_number(subject.details["From"]))
      end

      it { assert_defaults! }
    end

    context "phone call exists" do
      let(:remote_call_id) { SecureRandom.uuid }
      let(:phone_call_factory_attributes) { { :remote_call_id => remote_call_id } }

      def phone_call
        @phone_call ||= create(:phone_call, phone_call_factory_attributes)
      end

      let(:details) {
        details = generate(:twilio_remote_call_event_details)
        details["CallSid"] = remote_call_id
        details
      }
      let(:factory_attributes) { { :details => details } }

      def setup_scenario
        phone_call
        super
      end

      context "with no call flow logic" do
        it { assert_defaults! }
      end

      context "with invalid call flow logic" do
        # this can happen if we remote call flow logic from the application
        # we still want the event to be created
        # but it should use the default call flow logic instead

        def phone_call
          @phone_call ||= begin
            phone_call = super
            phone_call.update_column(:call_flow_logic, "Callout")
            phone_call
          end
        end

        it {
          assert_defaults!
          subject.save!
          expect(phone_call.reload.call_flow_logic).to eq(subject.call_flow_logic)
        }
      end
    end
  end
end
