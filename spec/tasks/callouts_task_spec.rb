require 'rails_helper'

RSpec.describe CalloutsTask do
  describe ".rake_tasks" do
    it { expect(described_class.rake_tasks).to eq([:start!, :stop!, :pause!, :resume!]) }
  end

  describe "#callout" do
    before do
      setup_scenario
    end

    let(:callout_task_callout_id) { nil }
    let(:callout) { create(:callout) }
    let(:result) { subject.callout }

    def setup_scenario
      stub_env(env)
    end

    def env
      {
        "CALLOUT_TASK_CALLOUT_ID" => callout_task_callout_id
      }
    end

    def assert_result!
      expect(result).to eq(asserted_result)
    end

    def assert_result_not_found!
      expect { result }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "no callouts exist" do
      it { assert_result_not_found! }
    end

    context "callouts exist" do
      let(:asserted_result) { callout }

      def setup_scenario
        super
        callout
      end

      context "one callout exists" do
        context "by default" do
          it { assert_result! }
        end

        context "setting CALLOUT_TASK_CALLOUT_ID to an id that doesn't exist" do
          let(:callout_task_callout_id) { 0 }
          it { assert_result_not_found! }
        end

        context "setting CALLOUT_TASK_CALLOUT_ID to an id that exists" do
          let(:callout_task_callout_id) { callout.id }
          it { assert_result! }
        end
      end

      context "multiple callouts exist" do
        let(:asserted_result) { callout }

        def setup_scenario
          super
          create(:callout)
        end

        context "by default" do
          it { assert_result_not_found! }
        end

        context "setting CALLOUT_TASK_CALLOUT_ID to an id that doesn't exist" do
          let(:callout_task_callout_id) { 0 }
          it { assert_result_not_found! }
        end

        context "setting CALLOUT_TASK_CALLOUT_ID to an id that exists" do
          let(:callout_task_callout_id) { callout.id }
          it { assert_result! }
        end
      end
    end
  end

  describe "events" do
    let(:callout) { create(:callout, "can_#{callout_event}".gsub(/!$/, "").to_sym) }

    before do
      setup_scenario
    end

    def setup_scenario
      callout
    end

    def assert_event!
      expect(subject.public_send(callout_event)).to eq(true)
    end

    [:start!, :stop!, :pause!, :resume!].each do |callout_event|
      describe "##{callout_event}" do
        let(:callout_event) { callout_event }
        it { assert_event! }
      end
    end
  end
end
