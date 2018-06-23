require "rails_helper"

RSpec.describe Sensor do
  describe "associations" do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_many(:sensor_rules).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:sensor_events).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:account) }
    it { is_expected.to validate_presence_of(:commune_ids) }
    it { is_expected.to validate_presence_of(:external_id) }

    context "persisted" do
      subject { create(:sensor) }

      it { is_expected.to validate_uniqueness_of(:external_id).scoped_to(:account_id) }
    end
  end

  describe "#map_link" do
    it "returns a link to google maps" do
      sensor = build_stubbed(
        :sensor,
        latitude: "11.5627465",
        longitude: "104.9104493"
      )

      expect(sensor.map_link).to eq("https://maps.google.com/?q=11.5627465,104.9104493")
    end

    it "returns nil if missing latitude or longitude" do
      sensor = build_stubbed(:sensor)
      expect(sensor.map_link).to eq(nil)
    end
  end
end
