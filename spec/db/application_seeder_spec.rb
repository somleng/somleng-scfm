require "rails_helper"
require Rails.root.join("db/application_seeder")

RSpec.describe ApplicationSeeder do
  let(:initialization_options) { {} }
  subject { described_class.new(initialization_options) }

  describe "#seed!" do
    let(:asserted_outputs) { [] }

    def env
      {}
    end

    def seed!
      subject.seed!
    end

    def assert_seed!
      assert_outputs!(asserted_outputs) { seed! }
    end

    def assert_outputs!(asserted_outputs)
      expectation = expect { yield }

      if asserted_outputs.empty?
        expectation.not_to output.to_stdout
      else
        expectation.to output(
          Regexp.new(asserted_outputs.join(".+"), Regexp::MULTILINE)
        ).to_stdout
      end
    end

    context "by default" do
      def assert_seed!
        super
        expect(Account.count).to eq(0)
      end

      it { assert_seed! }
    end

    context "CREATE_SUPER_ADMIN_ACCOUNT=1" do
      def env
        super.merge("CREATE_SUPER_ADMIN_ACCOUNT" => "1")
      end

      def assert_seed!
        super
        expect(Account.with_permissions(:super_admin).count).to eq(1)
        expect(Account.count).to eq(1)
        created_account = Account.first!
        expect(created_account.access_tokens.count).to eq(1)
      end

      context "by default" do
        it { assert_seed! }
      end

      context "OUTPUT=super_admin" do
        def env
          super.merge("OUTPUT" => "super_admin", "FORMAT" => format)
        end

        context "FORMAT=human" do
          let(:format) { :human }
          let(:asserted_outputs) { ["Super Admin Account Access Token"] }
          it { assert_seed! }
        end

        context "FORMAT=http_basic" do
          let(:format) { :http_basic }
          let(:asserted_outputs) { ["[\da-f]+"] }
          it { assert_seed! }
        end
      end
    end
  end
end
