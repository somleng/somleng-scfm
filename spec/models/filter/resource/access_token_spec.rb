require 'rails_helper'

RSpec.describe Filter::Resource::AccessToken do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :access_token }
  let(:association_chain) { AccessToken }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "timestamp_attribute_filter"
  end
end
