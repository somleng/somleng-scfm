require 'rails_helper'

RSpec.describe Filter::Resource::Callout do
  let(:filterable_factory) { :callout }
  let(:association_chain) { Callout.all }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "timestamp_attribute_filter"
    include_examples(
      "string_attribute_filter",
      :status => Callout::STATE_RUNNING.to_s,
      :call_flow_logic => CallFlowLogic::HelloWorld.to_s
    )
  end
end
