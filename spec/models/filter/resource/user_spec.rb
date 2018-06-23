require "rails_helper"

RSpec.describe Filter::Resource::User do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :user }
  let(:association_chain) { User }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "timestamp_attribute_filter"
  end
end
