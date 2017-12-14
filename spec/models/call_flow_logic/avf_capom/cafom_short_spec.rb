require 'rails_helper'

RSpec.describe CallFlowLogic::AvfCapom::CapomShort do
  include SomlengScfm::SpecHelpers::AvfCapomCallFlowLogic::BaseHelpers

  subject { described_class.new(:event => event, :current_url => current_url) }

  it_behaves_like("call_flow_logic")
  it_behaves_like("avf_capom_call_flow_logic")

  describe "#to_xml" do
    include SomlengScfm::SpecHelpers::AvfCapomCallFlowLogic::ToXmlHelpers
    include_examples("avf_capom_call_flow_logic_to_xml")
  end

  describe "#run!" do
    include SomlengScfm::SpecHelpers::AvfCapomCallFlowLogic::RunHelpers
    include_examples("avf_capom_call_flow_logic_run")

    context "status: '#{described_class::STATE_GATHERING_RECEIVED_TRANSFER}'" do
      let(:status) { described_class::STATE_GATHERING_RECEIVED_TRANSFER }
      include_examples(
        "dtmf_yes_no_state_transition",
        :asserted_yes_status => described_class::STATE_GATHERING_FEE_PAID,
        :asserted_no_status => described_class::STATE_RECORDING_TRANSFER_NOT_RECEIVED_REASON
      )
    end

    context "status: '#{described_class::STATE_RECORDING_GOODS_PURCHASED}'" do
      let(:status) { described_class::STATE_RECORDING_GOODS_PURCHASED }
      let(:asserted_new_status) { described_class::STATE_GATHERING_SAFE_AT_VENUE }
      it { assert_run! }
    end

    context "status: '#{described_class::STATE_GATHERING_SAFE_AT_VENUE}'" do
      let(:status) { described_class::STATE_GATHERING_SAFE_AT_VENUE }
      include_examples(
        "dtmf_yes_no_state_transition",
        :asserted_yes_status => described_class::STATE_PLAYING_COMPLETED_SURVEY_MESSAGE,
        :asserted_no_status => described_class::STATE_PLAYING_COMPLETED_SURVEY_MESSAGE
      )
    end
  end
end
