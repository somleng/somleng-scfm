require 'rails_helper'

RSpec.describe CalloutEvent do
  describe "validations" do
    def assert_validations!
      is_expected.to validate_inclusion_of(:event).in_array(Callout.aasm.events.map { |event| event.name.to_s })
      is_expected.to validate_presence_of(:callout)
    end

    it { assert_validations! }
  end

  describe "#save" do
    let(:callback) { create(:callout) }
    subject { described_class.new(:callout => callback, :event => event) }

    context "invalid" do
      let(:event) { "foo" }

      it {
        expect(subject.save).to eq(false)
        expect(subject.callout).to be_initialized
      }
    end

    context "valid" do
      let(:event) { "start" }

      it {
        expect(subject.save).to eq(true)
        expect(subject.callout).to be_running
      }
    end
  end
end
