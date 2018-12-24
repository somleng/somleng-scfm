require "rails_helper"

RSpec.describe Filter::Resource::Contact do
  let(:filterable_factory) { :contact }
  let(:association_chain) { Contact.all }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "msisdn_attribute_filter"
    include_examples "timestamp_attribute_filter"
  end
end
