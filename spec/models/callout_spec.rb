require "rails_helper"

RSpec.describe Callout do
  let(:factory) { :callout }
  include_examples "has_call_flow_logic"

  describe "associations" do
    it { is_expected.to have_many(:callout_participations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:batch_operations).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:audio_file) }

    context "#audio_file" do
      it "validates the content type" do
        callout = build(:callout, audio_file: "image.jpg")

        expect(callout).not_to be_valid
        expect(callout.errors[:audio_file]).to be_present
      end

      it "validates the file size" do
        callout = build(:callout, audio_file: "big_file.mp3")

        expect(callout).not_to be_valid
        expect(callout.errors[:audio_file]).to be_present
      end

      it "allows small audio files" do
        callout = build(:callout, audio_file: "test.mp3")
        expect(callout).to be_valid
      end
    end

    it "validates the province is permitted" do
      user = create(:user, province_ids: %w[11 12])
      callout = build(
        :callout,
        account: user.account,
        created_by: user,
        commune_ids: ["020101"]
      )

      expect(callout).not_to be_valid
      expect(callout.errors[:commune_ids]).not_to be_empty

      user.province_ids = nil
      expect(callout).to be_valid

      callout.created_by = nil
      expect(callout).to be_valid
    end
  end

  context "saving" do
    it { expect { create(:callout) }.to broadcast(:callout_committed) }
  end

  describe "audio_file=" do
    it "tracks changes when attaching a new audio file" do
      callout = described_class.new
      callout.audio_file = fixture_file_upload("files/test.mp3", "audio/mp3")

      expect(callout.audio_file_blob_changed?).to eq(true)
      expect(callout.audio_file_blob_was).to eq(nil)
    end

    it "tracks changes when updating the audio file" do
      callout = build(:callout, audio_file: "test.mp3")
      original_blob = callout.audio_file.blob
      callout.audio_file = fixture_file_upload("files/big_file.mp3", "audio/mp3")

      expect(callout.audio_file_blob_changed?).to eq(true)
      expect(callout.audio_file_blob_was).to eq(original_blob)
    end

    it "tracks changes when not updating the audio file" do
      callout = create(:callout, audio_file: "test.mp3")
      callout = Callout.find(callout.id)

      expect(callout.audio_file_blob_changed?).to eq(false)
    end

    context "province_permitted" do
      it "when created_by present, province must be in created_by provinces" do
        user = create(:user, province_ids: ["01"])
        callout = build(:callout, created_by: user, commune_ids: ["020101"])

        expect(callout.valid?).to eq false
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
