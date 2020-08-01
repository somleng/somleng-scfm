require "rails_helper"

RSpec.describe Preview::PhoneCallCreate do
  it "previews callout participations and contacts" do
    callout = create(:callout, :running)
    callout_participation = create_callout_participation(
      account: callout.account,
      callout: callout,
      metadata: { "foo" => "bar" }
    )
    other_callout_participation = create(
      :callout_participation,
      callout: create(:callout, :running),
      metadata: { "foo" => "bar" }
    )
    batch_operation = create_batch_operation(
      callout_participation_filter_params: {
        metadata: { "foo" => "bar" }
      },
      callout_filter_params: { status: :running }
    )

    preview = Preview::PhoneCallCreate.new(previewable: batch_operation)

    expect(
      preview.callout_participations(scope: CalloutParticipation)
    ).to match_array([callout_participation, other_callout_participation])
    expect(
      preview.callout_participations(scope: callout.account.callout_participations)
    ).to match_array([callout_participation])
    expect(
      preview.contacts(scope: Contact)
    ).to match_array([callout_participation.contact, other_callout_participation.contact])
    expect(
      preview.contacts(scope: callout.account.contacts)
    ).to match_array([callout_participation.contact])
  end

  def create_batch_operation(callout_participation_filter_params:, callout_filter_params:)
    create(
      :phone_call_create_batch_operation,
      callout_participation_filter_params: callout_participation_filter_params,
      callout_filter_params: callout_filter_params
    )
  end
end
