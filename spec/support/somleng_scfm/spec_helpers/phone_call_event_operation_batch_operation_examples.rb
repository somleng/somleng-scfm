RSpec.shared_examples_for("phone_call_event_operation_batch_operation") do
  include_examples("hash_store_accessor", :phone_call_filter_params)

  describe "validations" do
    context "phone_calls_preview" do
      let(:skip_validate_preview_presence) { nil }
      subject { build(factory, :skip_validate_preview_presence => skip_validate_preview_presence) }

      context "by default" do
        context "no phone calls in preview" do
          it {
            is_expected.not_to be_valid
            expect(subject.errors[:phone_calls_preview]).not_to be_empty
          }
        end

        context "phone calls in preview" do
          def setup_scenario
            create(:phone_call)
          end

          it { is_expected.to be_valid }
        end
      end

      context "skip_validate_preview_presence=true" do
        let(:skip_validate_preview_presence) { true }
        it { is_expected.to be_valid }
      end
    end
  end

  describe "state_machine" do
    describe "#finish!" do
      let(:phone_call) { create(:phone_call) }
      subject {
        create(
          factory,
          :status => BatchOperation::Base::STATE_RUNNING,
          :skip_validate_preview_presence => nil,
        )
      }

      def setup_scenario
        phone_call
        subject
        phone_call.destroy
        subject.finish!
      end

      it { expect(subject).to be_finished }
    end
  end

  describe "#run!" do
    let(:phone_call) { create(:phone_call, phone_call_factory_attributes) }
    subject { create(factory) }

    def setup_scenario
      super
      phone_call
      subject.run!
    end

    context "actioned successfully" do
      let(:actioned_phone_call) { subject.reload.phone_calls.first }

      it {
        expect(actioned_phone_call).to be_present
        expect(subject.phone_calls.size).to eq(1)
        expect(actioned_phone_call.status).to eq(asserted_status_after_run.to_s)
      }
    end

    context "not actioned successfully" do
      let(:phone_call_factory_attributes) { { :status => invalid_transition_status } }
      it { expect(subject.reload.phone_calls).to be_empty }
    end
  end
end
