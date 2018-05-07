require "rails_helper"

RSpec.describe Callout do
  let(:factory) { :callout }
  include_examples "has_metadata"
  include_examples "has_call_flow_logic"

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:account)
      is_expected.to have_many(:callout_participations).dependent(:restrict_with_error)
      is_expected.to have_many(:batch_operations).dependent(:restrict_with_error)
      is_expected.to have_many(:contacts)
      is_expected.to have_many(:phone_calls)
      is_expected.to have_many(:remote_phone_call_events)
    end

    it { assert_associations! }
  end

  describe "validations" do
    def assert_validations!
      is_expected.to validate_presence_of(:status)
      is_expected.to validate_presence_of(:province_id).on(:dashboard)
      is_expected.to validate_presence_of(:commune_ids).on(:dashboard)
    end

    it { assert_validations! }

    context "commune_ids" do
      it "has to be an array" do
        callout = build(:callout, commune_ids: nil)

        expect(callout.valid?(:dashboard)).to eq(false)
        expect(callout.errors[:commune_ids]).not_to eq nil
      end

      it "have to match with province_id" do
        callout = build(:callout, province_id: "04", commune_ids: ["030101"])

        expect(callout.valid?(:dashboard)).to eq(false)
        expect(callout.errors[:commune_ids]).not_to eq nil
      end
    end
  end

  describe "state_machine" do
    subject { create(factory, factory_attributes) }

    def factory_attributes
      { status: current_status }
    end

    def assert_transitions!
      is_expected.to transition_from(current_status).to(asserted_new_status).on_event(event)
    end

    describe "#start!" do
      let(:current_status) { :initialized }
      let(:asserted_new_status) { :running }
      let(:event) { :start }

      it { assert_transitions! }
    end

    describe "#pause!" do
      let(:current_status) { :running }
      let(:asserted_new_status) { :paused }
      let(:event) { :pause }

      it { assert_transitions! }
    end

    describe "#resume!" do
      let(:asserted_new_status) { :running }
      let(:event) { :resume }

      %i[paused stopped].each do |current_status|
        context "status: '#{current_status}'" do
          let(:current_status) { current_status }
          it { assert_transitions! }
        end
      end
    end

    describe "#stop!" do
      let(:asserted_new_status) { :stopped }
      let(:event) { :stop }

      %i[running paused].each do |current_status|
        context "status: '#{current_status}'" do
          let(:current_status) { current_status }
          it { assert_transitions! }
        end
      end
    end
  end
end
