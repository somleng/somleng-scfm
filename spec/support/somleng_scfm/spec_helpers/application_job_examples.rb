RSpec.shared_examples_for("application_job") do
  describe ".queue_name(job_name = nil)" do
    let(:args) { [] }

    def env
      env = super
      queue_name_env_key.present? ? super.merge(queue_name_env_key => queue_name) : env
    end

    def assert_queue_name!
      expect(described_class.queue_name(*args)).to eq(asserted_queue_name)
    end

    def build_queue_name(key)
      ["active_job", key, "queue_name"].join("_").upcase
    end

    context "job_name is given" do
      let(:job_name) { "job_name" }
      let(:queue_name) { "my-job-name-queue" }
      let(:queue_name_env_key) {
        build_queue_name(job_name)
      }

      let(:args) { [job_name] }
      let(:asserted_queue_name) { queue_name }

      it { assert_queue_name! }
    end

    context "queue name is configured" do
      let(:queue_name) { "my-queue" }
      let(:queue_name_env_key) {
        build_queue_name(described_class.to_s.underscore)
      }

      let(:asserted_queue_name) { queue_name }
      it { assert_queue_name! }
    end

    context "queue name is not configured" do
      context "default queue name is configured" do
        let(:queue_name_env_key) { "ACTIVE_JOB_QUEUE_NAME" }
        let(:queue_name) { "my-default-queue" }
        let(:asserted_queue_name) { queue_name }

        it { assert_queue_name! }
      end

      context "default queue name is not configured" do
        let(:queue_name_env_key) { nil }
        let(:asserted_queue_name) { ApplicationJob::DEFAULT_QUEUE_NAME }
        it { assert_queue_name! }
      end
    end
  end
end
