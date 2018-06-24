require "rails_helper"

RSpec.describe SensorRule do
  describe "associations" do
    it { is_expected.to belong_to(:sensor) }
    it { is_expected.to have_many(:sensor_events).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:level) }
    it { is_expected.to validate_numericality_of(:level).only_integer }

    context "alert_file" do
      it "must be present" do
        sensor_rule = build(:sensor_rule, alert_filename: nil)

        expect(sensor_rule).not_to be_valid
        expect(sensor_rule.errors[:alert_file]).to be_present
      end

      it "must be audio file" do
        sensor_rule = build(:sensor_rule, alert_filename: "image.jpg")

        sensor_rule.valid?

        expect(sensor_rule.errors[:alert_file]).to be_present
      end

      it "file cannot be bigger than 10MB" do
        sensor_rule = build(:sensor_rule, alert_filename: "big_file.mp3")

        sensor_rule.valid?

        expect(sensor_rule.errors[:alert_file]).to be_present
      end
    end
  end

  describe ".find_by_highest_level" do
    it "returns a sensor rule by matching the highest rule's level" do
      lower_level = create(:sensor_rule, level: 100)
      higher_level = create(:sensor_rule, level: 200)

      expect(SensorRule.find_by_highest_level(50)).to eq(nil)
      expect(SensorRule.find_by_highest_level(150)).to eq(lower_level)
      expect(SensorRule.find_by_highest_level(250)).to eq(higher_level)
    end
  end
end
