require 'rails_helper'

RSpec.describe CalloutsTask do
  describe CalloutsTask::Install do
    describe ".rake_tasks" do
      it { expect(described_class.rake_tasks).to eq([:run!, :create!, :statistics]) }
    end
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
        "CALLOUTS_TASK_CALLOUT_ID" => callout_task_callout_id
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

  describe "#run!" do
    let(:callout) { create(:callout, "can_#{callout_event}".gsub(/!$/, "").to_sym) }

    before do
      setup_scenario
    end

    def setup_scenario
      stub_env(env)
      callout
    end

    def env
      {
        "CALLOUTS_TASK_ACTION" => callouts_task_action.to_s
      }
    end

    def assert_event!
      expect(subject.run!).to eq(true)
    end

    [:start, :stop, :pause, :resume].each do |callout_event|
      context "CALLOUTS_TASK_ACTION='#{callout_event}'" do
        let(:callout_event) { callout_event }
        let(:callouts_task_action) { callout_event }
        it { assert_event! }
      end
    end

    context "CALLOUTS_TASK_ACTION=" do
      let(:callout_event) { :start }
      let(:callouts_task_action) { nil }
      it { expect { subject.run! }.to raise_error(ArgumentError) }
    end

    context "CALLOUTS_TASK_ACTION='delete'" do
      let(:callout_event) { :start }
      let(:callouts_task_action) { "delete" }
      it { expect { subject.run! }.to raise_error(ArgumentError) }
    end
  end

  describe "#create!" do
    let(:existing_callout) { create(:callout) }
    let(:force_create) { nil }
    let(:metadata) { nil }
    let(:result) { subject.create! }

    before do
      setup_scenario
    end

    def setup_scenario
      allow(STDOUT).to receive(:puts)
      stub_env(env)
    end

    def env
      {
        "CALLOUTS_TASK_FORCE_CREATE" => force_create && force_create.to_s,
        "CALLOUTS_TASK_CREATE_METADATA" => metadata && metadata.to_json
      }
    end

    def assert_create!
      expect(STDOUT).to receive(:puts) do |arg|
        assert_callout_id!(arg)
      end
      expect(result).to eq(Callout.last!)
    end

    context "given a callout does not yet exist" do
      def assert_callout_id!(arg)
      end

      it { assert_create! }

      context "specifying metadata" do
        let(:metadata) { { "foo" => "bar" } }

        def assert_create!

          expect(result.metadata).to eq(metadata)
        end

        it { assert_create! }
      end
    end

    context "given a callout already exists" do
      def setup_scenario
        super
        existing_callout
      end

      context "by default" do
        let(:asserted_callout) { existing_callout }

        def assert_callout_id!(id)
          expect(id).to eq(existing_callout.id)
        end

        it { assert_create! }
      end

      context "CALLOUTS_TASK_FORCE_CREATE=1" do
        let(:force_create) { 1 }
        let(:asserted_callout) { Callout.where.not(:id => existing_callout.id).last! }

        def assert_callout_id!(id)
          expect(id).not_to eq(existing_callout.id)
        end

        it { assert_create! }
      end
    end
  end

  describe "#statistics" do
    let(:callout) { create(:callout) }

    before do
      setup_scenario
    end

    def setup_scenario
      callout
    end

    def assert_statistics!
      expect(STDOUT).to receive(:puts) do |arg|
        expect(arg).to include("Callout Status")
      end
      subject.statistics
    end

    it { assert_statistics! }
  end
end
