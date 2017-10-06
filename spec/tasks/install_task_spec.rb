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

    def somleng_assertions
      [
        "SOMLENG_CLIENT_REST_API_HOST",
        "SOMLENG_CLIENT_REST_API_BASE_URL",
        "SOMLENG_ACCOUNT_SID",
        "SOMLENG_AUTH_TOKEN"
      ]
    end

    def assertions
      {
        "callouts_task_run" => {
          :global_assertions => [],
          :assertions => [
            "RAILS_ENV='production'",
            "CALLOUTS_TASK_ACTION"
          ]
        },
        "enqueue_calls_task_run" => {
          :assertions => [
            "ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE",
            "ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY",
            "ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE",
            "ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS"
          ] + somleng_assertions
        },
        "update_calls_task_run" => {
          :assertions => [
            "UPDATE_CALLS_TASK_MAX_CALLS_TO_FETCH",
            "PHONE_CALL_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS"
          ] + somleng_assertions
        },
        "start_flow_rapidpro_task_run" => {
          :assertions => [
            "RAPIDPRO_BASE_URL",
            "RAPIDPRO_API_VERSION",
            "RAPIDPRO_API_TOKEN"
          ]
        }
      }
    end

    def default_global_assertions
      [
        "RAILS_ENV='production'",
        "PHONE_CALL_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS"
      ]
    end

    def assert_cron!
      assertions.each do |filename, assertion_options|
        path = Rails.root.join("install", "cron", filename)
        contents = File.read(path)

        assertions = assertion_options[:assertions] || []
        assertions.each do |assertion|
          expect(contents).to include(assertion)
        end

        global_assertions = assertion_options[:global_assertions] || default_global_assertions
        global_assertions.each do |global_assertion|
          expect(contents).to include(global_assertion)
        end

        expect(contents.last).to eq("\n")
        expect(File.stat(path).mode.to_s(8)[3..5]).to eq("764")
      end
    end

    it { assert_cron! }
  end
end
