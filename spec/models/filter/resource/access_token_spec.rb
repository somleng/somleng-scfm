require "rails_helper"

RSpec.describe Filter::Resource::AccessToken do
  let(:filterable_factory) { :access_token }
  let(:association_chain) { AccessToken.all }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "timestamp_attribute_filter"
  end
end
