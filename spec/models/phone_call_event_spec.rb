require 'rails_helper'

RSpec.describe PhoneCallEvent do
  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:phone_call).validate(true)
    end

    it { assert_associations! }
  end
end
