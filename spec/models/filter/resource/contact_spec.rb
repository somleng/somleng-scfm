require 'rails_helper'

RSpec.describe Filter::Resource::Contact do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :contact }
  let(:association_chain) { Contact }

  it_behaves_like "metadata_attribute_filter"
  it_behaves_like "msisdn_attribute_filter"
end
