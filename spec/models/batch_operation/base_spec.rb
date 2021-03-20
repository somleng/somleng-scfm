require "rails_helper"

module BatchOperation
  RSpec.describe Base do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.not_to allow_value("foo").for(:parameters) }
    it { is_expected.to allow_value("foo" => "bar").for(:parameters) }

    it "serializes to json" do
      batch_operation = build_stubbed(:batch_operation)
      expect(JSON.parse(batch_operation.to_json)).to have_key("type")
    end

    describe ".from_type_param" do
      it "returns the correct batch operation" do
        expect(
          BatchOperation::Base.from_type_param(nil)
        ).to eq([])

        expect(
          BatchOperation::Base.from_type_param("foo")
        ).to eq([])

        expect(
          BatchOperation::Base.from_type_param(
            "BatchOperation::CalloutPopulation"
          )
        ).to eq(BatchOperation::CalloutPopulation)
      end
    end

    describe "states" do
      it "queues a batch operation" do
        expect(
          create(:batch_operation, :queued)
        ).to transition_from(:preview).to(:queued).on_event(:queue)
      end

      it "starts a batch operation" do
        expect(
          create(:batch_operation, :queued)
        ).to transition_from(:queued).to(:running).on_event(:start)
      end

      it "finishes a batch operation" do
        expect(
          create(:batch_operation, :running)
        ).to transition_from(:running).to(:finished).on_event(:finish)
      end

      it "requeues a batch operation" do
        expect(
          create(:batch_operation, :finished)
        ).to transition_from(:finished).to(:queued).on_event(:requeue)

        expect {
          create(:batch_operation, :finished).requeue!
        }.to broadcast(:batch_operation_queued)
      end
    end
  end
end
