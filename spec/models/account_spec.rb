require 'rails_helper'

RSpec.describe Account do
  let(:factory) { :account }
  include_examples "has_metadata"

  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:restrict_with_error) }
  end
end
