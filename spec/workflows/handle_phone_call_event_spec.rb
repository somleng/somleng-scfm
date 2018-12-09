require "rails_helper"

RSpec.describe HandlePhoneCallEvent do
  include FactoryHelpers

  class MyCallFlowLogic < CallFlowLogic::Base; end

  it "handles new phone calls" do
    account = create_account(call_flow_logic: MyCallFlowLogic)
    event_details = generate_event_details(
      account: account, direction: "inbound", call_status: "in-progress"
    )

    result = described_class.call(url, event_details)

    expect(result).to be_a(MyCallFlowLogic)
    expect(result.current_url).to eq(url)

    event = result.event
    expect(event).to be_persisted
    expect(event.details).to eq(event_details.stringify_keys)
    expect(event.remote_call_id).to eq(event_details.fetch(:CallSid))
    expect(event.remote_direction).to eq("inbound")
    expect(event.call_flow_logic).to eq(MyCallFlowLogic.to_s)

    expect(event.phone_call).to be_persisted
    expect(event.phone_call).to be_in_progress
    expect(event.phone_call.remote_call_id).to eq(event.remote_call_id)
    expect(event.phone_call.remote_direction).to eq("inbound")
    expect(event.phone_call.msisdn).to match(event_details.fetch(:From))
    expect(event.phone_call.remote_status).to eq("in-progress")
  end

  it "handles existing phone calls" do
    account = create_account(call_flow_logic: MyCallFlowLogic)
    phone_call = create_phone_call(
      :remotely_queued,
      account: account,
      call_flow_logic: CallFlowLogic::HelloWorld,
      remote_status: "queued"
    )
    event_details = generate_event_details(
      account: account,
      remote_call_id: phone_call.remote_call_id,
      call_status: "completed",
      call_duration: "87"
    )

    result = described_class.call(url, event_details)

    expect(result).to be_a(CallFlowLogic::HelloWorld)

    event = result.event
    expect(event.phone_call).to eq(phone_call)
    expect(event.call_duration).to eq(87)
    expect(event.phone_call.remote_status).to eq("completed")
    expect(event.phone_call).to be_completed
    expect(event.phone_call.duration).to eq(87)
  end

  it "does not override the phone call's duration" do
    account = create(:account)
    phone_call = create_phone_call(
      :remotely_queued, account: account, duration: 87
    )
    event_details = generate_event_details(
      account: account,
      remote_call_id: phone_call.remote_call_id,
      call_duration: 0
    )

    event = described_class.call(url, event_details).event

    expect(event.phone_call).to eq(phone_call)
    expect(event.phone_call.duration).to eq(87)
  end

  it "retries ActiveRecord::StaleObjectError exceptions" do
    account = create(:account)
    phone_call = create_phone_call(
      :remotely_queued, account: account
    )
    event_details = generate_event_details(
      account: account,
      remote_call_id: phone_call.remote_call_id
    )
    concurrent_event = RemotePhoneCallEvent.new(details: event_details, phone_call: phone_call)
    non_concurrent_event = RemotePhoneCallEvent.new(details: event_details)
    allow(RemotePhoneCallEvent).to receive(:new).and_return(concurrent_event, non_concurrent_event)
    PhoneCall.find(phone_call.id).touch

    event = described_class.call(url, event_details).event

    expect(event).to be_persisted
  end

  def create_account(call_flow_logic: nil)
    create(
      :account,
      somleng_account_sid: generate(:somleng_account_sid),
      call_flow_logic: call_flow_logic.to_s.presence
    )
  end

  def generate_event_details(options = {})
    {
      CallSid: options[:remote_call_id],
      AccountSid: options.fetch(:account).somleng_account_sid,
      CallStatus: options[:call_status],
      CallDuration: options[:call_duration],
      Direction: options[:direction]
    }.compact.reverse_merge(generate(:twilio_remote_call_event_details))
  end

  let(:url) { "https://wwww.example.com/api/remote_phone_call_events.xml" }
end
