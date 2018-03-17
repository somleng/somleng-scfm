require 'rails_helper'

RSpec.describe Filter::Resource::Account do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :account }
  let(:association_chain) { Account }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "timestamp_attribute_filter"
  end
end
