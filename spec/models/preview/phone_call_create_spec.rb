require "rails_helper"

RSpec.describe Preview::PhoneCallCreate do
  describe "#callout_participations" do
    it "returns filtered callout participations" do
      callout_status = Callout::STATE_RUNNING
      callout_participation_metadata = {
        "foo" => "bar",
        "bar" => "foo"
      }

      account = create(:account)

      callout_participation, other_callout_participation = create_callout_participations(
        account: account,
        metadata: callout_participation_metadata,
        callout_status: callout_status
      )

      batch_operation = create_batch_operation(
        metadata: {
          "foo" => "bar"
        },
        callout_status: callout_status
      )

      preview = described_class.new(
        previewable: batch_operation
      )

      expect(
        preview.callout_participations(scope: CalloutParticipation)
      ).to match_array([callout_participation, other_callout_participation])

      expect(
        preview.callout_participations(scope: account.callout_participations)
      ).to match_array([callout_participation])
    end
  end

  describe "#contacts" do
    it "returns filtered contacts" do
      callout_status = Callout::STATE_RUNNING
      callout_participation_metadata = {
        "foo" => "bar",
        "bar" => "foo"
      }

      account = create(:account)

      callout_participation, other_callout_participation = create_callout_participations(
        account: account,
        metadata: callout_participation_metadata,
        callout_status: callout_status
      )

      batch_operation = create_batch_operation(
        metadata: {
          "foo" => "bar"
        },
        callout_status: callout_status
      )

      preview = described_class.new(
        previewable: batch_operation
      )

      expect(
        preview.contacts(scope: Contact)
      ).to match_array([callout_participation.contact, other_callout_participation.contact])

      expect(
        preview.contacts(scope: account.contacts)
      ).to match_array([callout_participation.contact])
    end
  end

  def create_batch_operation(metadata:, callout_status:)
    create(
      :phone_call_create_batch_operation,
      callout_participation_filter_params: {
        metadata: metadata
      },
      callout_filter_params: {
        status: callout_status
      }
    )
  end

  def create_callout_participations(account:, metadata:, callout_status:)
    callout = create(:callout, status: callout_status, account: account)

    callout_participation = create_callout_participation(
      account: account,
      callout: callout,
      metadata: metadata
    )

    other_callout_participation = create(
      :callout_participation,
      callout: create(:callout, status: callout_status),
      metadata: metadata
    )

    _non_matching_callout_participation = create_callout_participation(
      account: account,
      callout: callout,
      metadata: {
        "foo" => "baz"
      }
    )

    _non_matching_callout_participation = create_callout_participation(
      account: account,
      callout: create(:callout, account: account),
      metadata: metadata
    )

    [callout_participation, other_callout_participation]
  end
end
