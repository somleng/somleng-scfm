RSpec.shared_examples_for("application_job") do
  describe ".queue_name" do
    def env
      env = super
      queue_name_env_key.present? ? super.merge(queue_name_env_key => queue_name) : env
    end

    def assert_queue_name!
      expect(described_class.queue_name).to eq(asserted_queue_name)
    end

    context "queue name is configured" do
      let(:queue_name) { "my-queue" }
      let(:queue_name_env_key) {
        [
          "active_job",
          described_class.to_s.underscore,
          "queue_name"
        ].join("_").upcase
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
