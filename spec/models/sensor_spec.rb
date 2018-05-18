require 'rails_helper'

RSpec.describe Sensor, type: :model do
  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:account)
    end

    it { assert_associations! }
  end

  describe "validations" do
    def assert_validations!
      is_expected.to validate_presence_of(:account)
      is_expected.to validate_presence_of(:province_id)
    end

    it { assert_validations! }
  end
end
