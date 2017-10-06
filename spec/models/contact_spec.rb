require 'rails_helper'

RSpec.describe Contact do
  let(:factory) { :contact }
  include_examples "has_metadata"

  describe "associations" do
    def assert_associations!
      is_expected.to have_many(:phone_numbers)
      is_expected.to have_many(:callouts)
    end

    it { assert_associations! }
  end
end
