require "rails_helper"

RSpec.describe Sensor do
  describe "associations" do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_many(:sensor_rules).dependent(:restrict_with_error) }
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
end
