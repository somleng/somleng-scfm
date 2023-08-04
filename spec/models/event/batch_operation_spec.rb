require "rails_helper"

RSpec.describe Event::BatchOperation do
  describe "validations" do
    it "can be queued" do
      batch_operation = create(:batch_operation, :preview)

      event = Event::BatchOperation.new(eventable: batch_operation, event: "queue")

      expect(event).to be_valid
    end

    it "cannot queue after finished" do
      batch_operation = create(:batch_operation, :finished)

      event = Event::BatchOperation.new(eventable: batch_operation, event: "queue")

      expect(event).to be_invalid
    end
  end
end
