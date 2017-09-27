require 'rails_helper'

RSpec.describe Callout do
  describe "associations" do
    def assert_associations!
      is_expected.to have_many(:phone_numbers)
    end

    it { assert_associations! }
  end
end
