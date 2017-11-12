require 'rails_helper'

RSpec.describe CalloutStatistics do
  let(:callout) { create(:callout) }

  subject { described_class.new(:callout => callout) }

  describe "#to_json" do
    let(:parsed_json) { JSON.parse(subject.to_json) }
    let(:asserted_keys) {
      [
        "callout_status",
        "callout_participations",
        "callout_participations_remaining",
        "callout_participations_completed",
        "calls_completed",
        "calls_initialized",
        "calls_fetching_status",
        "calls_waiting_for_completion",
        "calls_queued",
        "calls_in_progress",
        "calls_errored",
        "calls_failed",
        "calls_busy",
        "calls_not_answered",
        "calls_canceled"
      ]
    }

    def assert_json!
      expect(parsed_json.keys).to match_array(asserted_keys)
    end

    it { assert_json! }
  end
end
