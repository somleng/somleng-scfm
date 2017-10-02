require 'rails_helper'

RSpec.describe InstallTask do
  describe InstallTask::Install do
    describe ".rake_tasks" do
      it { expect(described_class.rake_tasks).to eq([:cron]) }
    end
  end

  describe "#cron" do
    include FakeFS::SpecHelpers

    Dir[Rails.root.join('app/tasks/**/*.rb')].each { |f| require f }

    before do
      setup_scenario
    end

    def setup_scenario
      subject.cron
    end

    def assertions
      {
        "callouts_task_run" => ["CALLOUTS_TASK_ACTION"]
      }
    end

    def assert_cron!
      assertions.each do |filename, assertions|
        path = Rails.root.join("install", "cron", filename)
        contents = File.read(path)
        assertions.each do |assertion|
          expect(contents).to include(assertion)
        end
        expect(contents.last).to eq("\n")
        expect(File.stat(path).mode.to_s(8)[3..5]).to eq("764")
      end
    end

    it { assert_cron! }
  end
end
