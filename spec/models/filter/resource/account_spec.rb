require "rails_helper"

RSpec.describe Filter::Resource::Account do
  let(:filterable_factory) { :account }
  let(:association_chain) { Account.all }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "timestamp_attribute_filter"
  end
end
