require 'rails_helper'

RSpec.describe SensorRule, type: :model do
  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:sensor)
    end

    it { assert_associations! }
  end

  describe "validations" do
    def assert_validations!
      is_expected.to validate_presence_of(:sensor)
      is_expected.to validate_presence_of(:level)
    end

    it { assert_validations! }

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
