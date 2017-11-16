require 'rails_helper'

RSpec.describe PhoneCall do
  let(:factory) { :phone_call }
  include_examples "has_metadata"
  include_examples "has_call_flow_logic"

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:callout_participation)
      is_expected.to belong_to(:contact).validate(true)
      is_expected.to belong_to(:create_batch_operation)
      is_expected.to belong_to(:queue_batch_operation)
      is_expected.to belong_to(:queue_remote_fetch_batch_operation)
      is_expected.to have_many(:remote_phone_call_events).dependent(:restrict_with_error)
    end

    it { assert_associations! }
  end

  describe "validations" do
    context "new record" do
      def assert_validations!
        is_expected.to validate_presence_of(:status)
      end

      context "for an inbound call" do
        subject { build(factory, :inbound) }
        it { is_expected.not_to validate_presence_of(:callout_participation) }
        it { is_expected.not_to validate_presence_of(:remote_request_params) }
      end

      context "for an outbound call" do
        it { is_expected.to validate_presence_of(:callout_participation) }
        it { is_expected.to validate_presence_of(:remote_request_params) }
      end

      context "remote_request_params" do
        subject { build(factory, :remote_request_params => {"foo" => "bar"}) }
        it { is_expected.not_to be_valid }
      end

      it { assert_validations! }
    end

    context "persisted" do
      subject { create(factory) }

      def assert_validations!
        is_expected.to validate_uniqueness_of(:remote_call_id).case_insensitive
        is_expected.to validate_presence_of(:msisdn)
      end

      it { assert_validations! }
    end
  end

  describe "defaults" do
    let(:factory_attributes) { {} }
    subject { build(factory, *factory_traits, factory_attributes) }

    def setup_scenario
      super
      subject.valid?
    end

    def assert_defaults!
      expect(subject.errors).to be_empty
      expect(subject.msisdn).to be_present
      expect(subject.contact).to be_present
    end

    context "outbound" do
      let(:factory_traits) { [:outbound] }
      it { assert_defaults! }

      def assert_defaults!
        super
        expect(subject.contact).to eq(subject.callout_participation.contact)
        expect(subject.msisdn).to eq(subject.callout_participation.msisdn)
      end
    end

    context "inbound" do
      let(:factory_traits) { [:inbound] }
      let(:msisdn) { generate(:somali_msisdn) }
      let(:factory_attributes) { { :msisdn => msisdn } }

      context "contact exists with matching msisdn" do
        let(:contact) { create(:contact, :msisdn => msisdn) }

        def setup_scenario
          contact
          super
        end

        def assert_defaults!
          super
          expect(subject.contact).to eq(contact)
          expect(subject.msisdn).to eq(contact.msisdn)
        end

        it { assert_defaults! }
      end

      context "contact does not exist" do
       def assert_defaults!
          super
          expect(subject.msisdn).to eq(subject.contact.msisdn)
        end
      end

      it { assert_defaults! }
    end
  end

  describe "destroying" do
    let(:factory_attributes) { {} }
    subject { create(factory, factory_attributes) }

    def setup_scenario
      super
      subject.destroy
    end

    context "allowed to destroy" do
      it {
        expect(described_class.find_by_id(subject.id)).to eq(nil)
      }
    end

    context "not allowed to destroy" do
      let(:status) { described_class::STATE_QUEUED }
      let(:factory_attributes) { { :status => status } }

      it {
        expect(described_class.find_by_id(subject.id)).to be_present
        expect(subject.errors[:base]).not_to be_empty
        expect(
          subject.errors[:base].first
        ).to eq(
          I18n.t!(
            "activerecord.errors.models.phone_call.attributes.base.restrict_destroy_status",
            :status => status
          )
        )
      }
    end
  end

  describe "state_machine" do
    subject { create(factory, factory_attributes) }

    def factory_attributes
      {:status => current_status}
    end

    def assert_transitions!
      is_expected.to transition_from(current_status).to(asserted_new_status).on_event(event)
    end

    def assert_not_transitioned!
      is_expected.not_to transition_from(current_status).to(asserted_new_status).on_event(event)
    end

    describe "#queue!" do
      let(:current_status) { described_class::STATE_CREATED }
      let(:asserted_new_status) { described_class::STATE_QUEUED }
      let(:event) { :queue }

      it { assert_transitions! }

      it("should broadcast") {
        assert_broadcasted!(:phone_call_queued) { subject.queue! }
      }
    end

    describe "#queue_remote!" do
      let(:current_status) { described_class::STATE_QUEUED }
      let(:event) { :queue_remote }

      context "touching timestamp" do
        def setup_scenario
          super
          subject.queue_remote!
        end

        it { expect(subject.remotely_queued_at).to be_present }
      end

      context "by default" do
        let(:asserted_new_status) { described_class::STATE_ERRORED }
        it { assert_transitions! }
      end

      context "remote_call_id is present" do
        let(:asserted_new_status) { described_class::STATE_REMOTELY_QUEUED }

        def factory_attributes
          super.merge(:remote_call_id => "1234")
        end

        it { assert_transitions! }
      end
    end

    describe "#queue_remote_fetch!" do
      def factory_attributes
        super.merge(:remote_call_id => remote_call_id)
      end

      let(:event) { :queue_remote_fetch }
      let(:current_status) { described_class::STATE_REMOTELY_QUEUED }
      let(:asserted_new_status) { described_class::STATE_REMOTE_FETCH_QUEUED }

      context "remote_call_id is present" do
        let(:remote_call_id) { "1234" }

        it { assert_transitions! }

        it("should broadcast") {
          assert_broadcasted!(:phone_call_remote_fetch_queued) { subject.queue_remote_fetch! }
        }
      end

      context "remote_call_id is not present" do
        let(:remote_call_id) { nil }
        it { assert_not_transitioned! }
      end
    end

    describe "#complete!" do
      let(:event) { :complete }

      def factory_attributes
        super.merge(:remote_status => remote_status)
      end

      context "new_remote_status: nil" do
        # this is set when fetching the remote call

        def factory_attributes
          super.merge(:new_remote_status => nil)
        end

        context "was not remotely queued (inbound call)" do
          context "current_status: 'in_progress'" do
            let(:remote_status) { "in-progress" }
            let(:current_status) { described_class::STATE_IN_PROGRESS }
            let(:asserted_new_status) { described_class::STATE_IN_PROGRESS }
            it { assert_transitions! }
          end
        end

        context "was remotely queued" do
          let(:remote_status) { "queued" }

          def factory_attributes
            super.merge(:remotely_queued_at => Time.now)
          end

          context "current_status: 'remote_fetch_queued'" do
            let(:current_status) { described_class::STATE_REMOTE_FETCH_QUEUED }
            let(:asserted_new_status) { described_class::STATE_REMOTELY_QUEUED }
            it { assert_transitions! }
          end
        end
      end

      [described_class::STATE_REMOTELY_QUEUED, described_class::STATE_IN_PROGRESS, described_class::STATE_REMOTE_FETCH_QUEUED].each do |current_status|
        context "status: '#{current_status}'" do
          let(:current_status) { current_status }
          {
            "ringing" => described_class::STATE_IN_PROGRESS,
            "in-progress" => described_class::STATE_IN_PROGRESS,
            "busy" => described_class::STATE_BUSY,
            "failed" => described_class::STATE_FAILED,
            "no-answer" => described_class::STATE_NOT_ANSWERED,
            "canceled" => described_class::STATE_CANCELED,
            "completed" => described_class::STATE_COMPLETED,
          }.each do |remote_status, asserted_new_status|
            context "remote_status: '#{remote_status}'" do
              let(:remote_status) { remote_status }
              let(:asserted_new_status) { asserted_new_status }
              it { assert_transitions! }
            end
          end
        end
      end
    end
  end

  describe "#remote_response" do
    it { expect(subject.remote_response).to eq({}) }
  end

  describe "#remote_request_params" do
    it { expect(subject.remote_request_params).to eq({}) }
  end

  describe "#remote_queue_response" do
    it { expect(subject.remote_queue_response).to eq({}) }
  end

  describe "scopes" do
    def assert_scope!
      expect(results).to match_array(asserted_results)
    end

    describe ".in_last_hours(hours, timestamp_column = :created_at)" do
      let(:remotely_queued_at) { nil }
      let(:created_at) { nil }

      def create_phone_call(*args)
        options = args.extract_options!
        create(factory, *args, factory_attributes.merge(options))
      end

      def factory_attributes
        {
          :created_at => created_at
        }
      end

      let(:phone_call) { create_phone_call }
      let(:queued_phone_call) { create_phone_call(:remotely_queued_at => remotely_queued_at) }

      let(:hours) { 1 }
      let(:timestamp_column) { nil }
      let(:args) { [hours, timestamp_column].compact }
      let(:results) { described_class.in_last_hours(*args) }

      def setup_scenario
        queued_phone_call
        phone_call
      end

      context "by default" do
        context "was created at more than specified hours ago" do
          let(:created_at) { hours.hours.ago }
          let(:asserted_results) { [] }
          it { assert_scope! }
        end

        context "was recently created" do
          let(:asserted_results) { [phone_call, queued_phone_call] }
          it { assert_scope! }
        end
      end

      context "passing timestamp_column = :remotely_queued_at" do
        let(:timestamp_column) { :remotely_queued_at }

        let(:asserted_results) { [queued_phone_call] }

        context "was recently queued" do
          let(:remotely_queued_at) { Time.now }
          it { assert_scope! }
        end

        context "was queued at more than specified hours ago" do
          let(:remotely_queued_at) { hours.hours.ago }
          let(:asserted_results) { [] }
          it { assert_scope! }
        end
      end
    end
  end
end
