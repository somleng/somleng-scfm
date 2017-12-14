require 'rails_helper'

RSpec.describe CallFlowLogic::Base do
  describe ".permitted" do
    let(:call_flow_logic) { CallFlowLogic::Application }
    let(:asserted_call_flow_logic) { call_flow_logic }

    def assert_permitted!
      expect(described_class.permitted).to include(asserted_call_flow_logic.to_s)
    end

    def setup_scenario
      described_class.permitted
      call_flow_logic
    end

    it { assert_permitted! }
  end

  describe ".register(*args)" do
    def assert_registered!
      expect(described_class.registered).to include(asserted_call_flow_logic.to_s)
    end

    def assert_not_registered!
      expect(described_class.registered).not_to include(asserted_call_flow_logic.to_s)
    end

    context "using environment variables" do
      let(:call_flow_logic) { CallFlowLogic::AvfCapom::CapomShort }
      let(:asserted_call_flow_logic) { call_flow_logic }

      def env
        super.merge("REGISTERED_CALL_FLOW_LOGIC" => call_flow_logic.to_s)
      end

      def setup_scenario
        super
        require Rails.root.join("config", "initializers", "call_flow_logic")
      end

      it { assert_registered! }
    end

    context "Registering invalid call flow logic" do
      let(:call_flow_logic) { Contact }
      let(:asserted_call_flow_logic) { call_flow_logic }

      def setup_scenario
        super
        described_class.register(call_flow_logic.to_s)
      end

      it { assert_not_registered! }
    end
  end
end
