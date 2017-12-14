require 'rails_helper'

RSpec.describe CallFlowLogic::AvfCapom::CapomLong do
  include SomlengScfm::SpecHelpers::AvfCapomCallFlowLogic::BaseHelpers

  subject { described_class.new(:event => event, :current_url => current_url) }

  it_behaves_like("call_flow_logic")
  it_behaves_like("avf_capom_call_flow_logic")

  describe "#to_xml" do
    include SomlengScfm::SpecHelpers::AvfCapomCallFlowLogic::ToXmlHelpers
    include_examples("avf_capom_call_flow_logic_to_xml")

    context "status: '#{described_class::STATE_GATHERING_RECEIVED_TRANSFER_AMOUNT}'" do
      let(:status) { described_class::STATE_GATHERING_RECEIVED_TRANSFER_AMOUNT }
      include_examples("twiml_gather", :num_digits => "3")
    end

    context "status: '#{described_class::STATE_GATHERING_PAID_FOR_TRANSPORT}'" do
      let(:status) { described_class::STATE_GATHERING_PAID_FOR_TRANSPORT }
      include_examples("twiml_gather", :num_digits => "1")
    end

    context "status: '#{described_class::STATE_GATHERING_PAID_FOR_TRANSPORT_AMOUNT}'" do
      let(:status) { described_class::STATE_GATHERING_PAID_FOR_TRANSPORT_AMOUNT }
      include_examples("twiml_gather", :num_digits => "3")
    end

    context "status: '#{described_class::STATE_RECORDING_GOODS_PURCHASED}'" do
      let(:status) { described_class::STATE_RECORDING_GOODS_PURCHASED }
      it { assert_play_and_record! }
    end

    context "status: '#{described_class::STATE_GATHERING_ITEM_AVAILABILITY}'" do
      let(:status) { described_class::STATE_GATHERING_ITEM_AVAILABILITY }
      include_examples("twiml_gather", :num_digits => "1")
    end

    context "status: '#{described_class::STATE_GATHERING_IDP_STATUS}'" do
      let(:status) { described_class::STATE_GATHERING_IDP_STATUS }
      include_examples("twiml_gather", :num_digits => "1")
    end

    context "status: '#{described_class::STATE_GATHERING_WATER_AVAILABILITY}'" do
      let(:status) { described_class::STATE_GATHERING_WATER_AVAILABILITY }
      include_examples("twiml_gather", :num_digits => "3")
    end

    context "status: '#{described_class::STATE_GATHERING_SICKNESS}'" do
      let(:status) { described_class::STATE_GATHERING_SICKNESS }
      include_examples("twiml_gather", :num_digits => "1")
    end

    context "status: '#{described_class::STATE_GATHERING_PREFERRED_TRANSFER_MODALITY}'" do
      let(:status) { described_class::STATE_GATHERING_PREFERRED_TRANSFER_MODALITY }
      include_examples("twiml_gather", :num_digits => "1")
    end
  end

  describe "#run!" do
    include SomlengScfm::SpecHelpers::AvfCapomCallFlowLogic::RunHelpers
    include_examples("avf_capom_call_flow_logic_run")

    context "status: '#{described_class::STATE_GATHERING_RECEIVED_TRANSFER}'" do
      let(:status) { described_class::STATE_GATHERING_RECEIVED_TRANSFER }
      include_examples(
        "dtmf_yes_no_state_transition",
        :asserted_yes_status => described_class::STATE_GATHERING_RECEIVED_TRANSFER_AMOUNT,
        :asserted_no_status => described_class::STATE_RECORDING_TRANSFER_NOT_RECEIVED_REASON
      )
    end

    context "status: '#{described_class::STATE_GATHERING_RECEIVED_TRANSFER_AMOUNT}'" do
      let(:status) { described_class::STATE_GATHERING_RECEIVED_TRANSFER_AMOUNT }
      include_examples(
        "dtmf_any_input_state_transition",
        :input => "500",
        :asserted_new_status => described_class::STATE_GATHERING_PAID_FOR_TRANSPORT,
      )
    end

    context "status: '#{described_class::STATE_GATHERING_PAID_FOR_TRANSPORT}'" do
      let(:status) { described_class::STATE_GATHERING_PAID_FOR_TRANSPORT }
      include_examples(
        "dtmf_yes_no_state_transition",
        :asserted_yes_status => described_class::STATE_GATHERING_PAID_FOR_TRANSPORT_AMOUNT,
        :asserted_no_status => described_class::STATE_GATHERING_SAFE_AT_VENUE
      )
    end

    context "status: '#{described_class::STATE_GATHERING_PAID_FOR_TRANSPORT_AMOUNT}'" do
      let(:status) { described_class::STATE_GATHERING_PAID_FOR_TRANSPORT_AMOUNT }
      include_examples(
        "dtmf_any_input_state_transition",
        :input => "500",
        :asserted_new_status => described_class::STATE_GATHERING_SAFE_AT_VENUE
      )
    end

    context "status: '#{described_class::STATE_GATHERING_SAFE_AT_VENUE}'" do
      let(:status) { described_class::STATE_GATHERING_SAFE_AT_VENUE }
      include_examples(
        "dtmf_yes_no_state_transition",
        :asserted_yes_status => described_class::STATE_GATHERING_FEE_PAID,
        :asserted_no_status => described_class::STATE_GATHERING_FEE_PAID
      )
    end

    context "status: '#{described_class::STATE_RECORDING_GOODS_PURCHASED}'" do
      let(:status) { described_class::STATE_RECORDING_GOODS_PURCHASED }
      let(:asserted_new_status) { described_class::STATE_GATHERING_ITEM_AVAILABILITY }
      it { assert_run! }
    end

    context "status: '#{described_class::STATE_GATHERING_ITEM_AVAILABILITY}'" do
      let(:status) { described_class::STATE_GATHERING_ITEM_AVAILABILITY }
      include_examples(
        "dtmf_yes_no_state_transition",
        :asserted_yes_status => described_class::STATE_GATHERING_IDP_STATUS,
        :asserted_no_status => described_class::STATE_GATHERING_IDP_STATUS
      )
    end

    context "status: '#{described_class::STATE_GATHERING_IDP_STATUS}'" do
      let(:status) { described_class::STATE_GATHERING_IDP_STATUS }
      include_examples(
        "dtmf_yes_no_state_transition",
        :asserted_yes_status => described_class::STATE_GATHERING_WATER_AVAILABILITY,
        :asserted_no_status => described_class::STATE_GATHERING_WATER_AVAILABILITY
      )
    end

    context "status: '#{described_class::STATE_GATHERING_WATER_AVAILABILITY}'" do
      let(:status) { described_class::STATE_GATHERING_WATER_AVAILABILITY }
      include_examples(
        "dtmf_any_input_state_transition",
        :input => "500",
        :asserted_new_status => described_class::STATE_GATHERING_SICKNESS
      )
    end

    context "status: '#{described_class::STATE_GATHERING_SICKNESS}'" do
      let(:status) { described_class::STATE_GATHERING_SICKNESS }
      include_examples(
        "dtmf_yes_no_state_transition",
        :asserted_yes_status => described_class::STATE_GATHERING_PREFERRED_TRANSFER_MODALITY,
        :asserted_no_status => described_class::STATE_GATHERING_PREFERRED_TRANSFER_MODALITY
      )
    end

    context "status: '#{described_class::STATE_GATHERING_PREFERRED_TRANSFER_MODALITY}'" do
      let(:status) { described_class::STATE_GATHERING_PREFERRED_TRANSFER_MODALITY }
      include_examples(
        "dtmf_yes_no_state_transition",
        :asserted_yes_status => described_class::STATE_PLAYING_COMPLETED_SURVEY_MESSAGE,
        :asserted_no_status => described_class::STATE_PLAYING_COMPLETED_SURVEY_MESSAGE
      )
    end
  end
end
