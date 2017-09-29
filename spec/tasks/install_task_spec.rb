require 'rails_helper'

RSpec.describe InstallTask do
  describe ".rake_tasks" do
    it { expect(described_class.rake_tasks).to eq([:cron]) }
  end

  describe "#cron" do
    Dir[Rails.root.join('app/tasks/**/*.rb')].each { |f| require f }

    def assert_cron!
      subject.cron
    end

    it { assert_cron! }
  end
end
