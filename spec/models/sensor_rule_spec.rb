require 'rails_helper'

RSpec.describe SensorRule do
  describe "associations" do
    it { is_expected.to belong_to(:sensor) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:level) }
    it { is_expected.to validate_numericality_of(:level).only_integer }

    context "voice" do
      it "must be present" do
        sensor_rule = build(:sensor_rule, voice_file: nil)

        sensor_rule.valid?

        expect(sensor_rule.errors[:voice]).to be_present
      end

      it "must be audio file" do
        sensor_rule = build(:sensor_rule, voice_file: "image.jpg")

        sensor_rule.valid?

        expect(sensor_rule.errors[:voice]).to be_present
      end

      it "file cannot be bigger than 10MB" do
        sensor_rule = build(:sensor_rule, voice_file: "big_file.mp3")

        sensor_rule.valid?

        expect(sensor_rule.errors[:voice]).to be_present
      end
    end
  end
end
