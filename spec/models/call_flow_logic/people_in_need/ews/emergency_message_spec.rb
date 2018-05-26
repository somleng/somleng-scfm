require "rails_helper"

RSpec.describe CallFlowLogic::PeopleInNeed::EWS::EmergencyMessage do
  it_behaves_like("call_flow_logic")

  describe "#to_xml" do
    fit "plays the emergency message" do
      account = create(:account)
      phone_call = create_phone_call(account: account)
      call_flow_logic = described_class.new(event: event)
      response = Hash.from_xml(xml)["Response"]
    end
  end

  def create_remote_phone_call_event(account:, **options)
    phone_call = options.delete(:phone_call) || create_phone_call(account: account)
    create(:remote_phone_call_event, phone_call: phone_call, **options)
  end
end
