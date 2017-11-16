require 'rails_helper'

RSpec.describe Filter::Resource::Callout do
  include SomlengScfm::SpecHelpers::FilterHelpers

  let(:filterable_factory) { :callout }
  let(:association_chain) { Callout }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "timestamp_attribute_filter"
    include_examples(
      "string_attribute_filter",
      :status => Callout::STATE_RUNNING.to_s,
      :call_flow_logic => CallFlowLogic::Application.to_s
    )
  end
end
