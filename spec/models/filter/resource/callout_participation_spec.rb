require 'rails_helper'

RSpec.describe Filter::Resource::CalloutParticipation do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :callout_participation }
  let(:association_chain) { CalloutParticipation }

  it_behaves_like "metadata_attribute_filter"
  it_behaves_like "msisdn_attribute_filter"

  describe "#resources" do
  end
end
