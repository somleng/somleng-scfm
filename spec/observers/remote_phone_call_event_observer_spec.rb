require 'rails_helper'

RSpec.describe RemotePhoneCallEventObserver do
  let(:factory_attributes) { {} }
  let(:event) { build(:remote_phone_call_event, factory_attributes) }
  let(:observe_event) { true }

  def setup_scenario
    super
    observe_event! if observe_event
  end

  describe "#remote_phone_call_event_initialized(remote_phone_call_event)" do
    let(:asserted_call_flow_logic) { described_class::DEFAULT_CALL_FLOW_LOGIC.to_s }

    def observe_event!
      subject.remote_phone_call_event_initialized(event)
    end

    def assert_observed!
      expect(event.errors).to be_empty
      expect(event.remote_call_id).to eq(event.details["CallSid"])
      expect(event.remote_direction).to eq(event.details["Direction"])
      expect(event.call_flow_logic).to eq(asserted_call_flow_logic)
      expect(event.phone_call.call_flow_logic).to eq(event.call_flow_logic)
    end

    context "phone call does not exist" do
      def assert_observed!
        super
        phone_call = event.phone_call
        expect(phone_call).to be_present
        expect(phone_call.remote_call_id).to eq(event.remote_call_id)
        expect(phone_call.remote_direction).to eq(event.remote_direction)
        expect(phone_call.msisdn).to eq(event.details["From"])
        expect(phone_call.remote_status).to eq(event.details["CallStatus"])
      end

      it { assert_observed! }
    end

    context "phone call exists" do
      let(:remote_call_id) { SecureRandom.uuid }
      let(:phone_call_factory_attributes) { { :remote_call_id => remote_call_id } }
      let(:observe_event) { false }

      def phone_call
        @phone_call ||= create(:phone_call, phone_call_factory_attributes)
      end

      let(:details) {
        details = generate(:twilio_remote_call_event_details)
        details["CallSid"] = remote_call_id
        details
      }

      let(:factory_attributes) {
        {
          :details => details,
          :call_flow_logic => nil,
          :build_phone_call => false
        }
      }

      class MyCallFlowLogic < CallFlowLogic::Base
      end

      let(:call_flow_logic) { MyCallFlowLogic.to_s }

      def setup_scenario
        super
        CallFlowLogic::Base.register(call_flow_logic)
        phone_call
        observe_event!
      end

      context "with no call flow logic" do
        context "by default" do
          it { assert_observed! }
        end

        context "DEFAULT_CALL_FLOW_LOGIC='MyCallFlowLogic'" do
          let(:asserted_call_flow_logic) { call_flow_logic }

          def env
            super.merge("DEFAULT_CALL_FLOW_LOGIC" => call_flow_logic)
          end

          it { assert_observed! }
        end
      end

      context "with valid call flow logic" do
        let(:phone_call_factory_attributes) { super().merge(:call_flow_logic => call_flow_logic) }
        let(:asserted_call_flow_logic) { call_flow_logic }

        it {
          assert_observed!
          event.save!
          expect(phone_call.reload.call_flow_logic).to eq(event.call_flow_logic)
        }
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
          assert_observed!
          event.save!
          expect(phone_call.reload.call_flow_logic).to eq(event.call_flow_logic)
        }
      end
    end
  end
end

