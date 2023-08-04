require "rails_helper"

module BatchOperation
  RSpec.describe CalloutPopulation do
    include_examples("hash_store_accessor", :contact_filter_params)

    it { is_expected.to belong_to(:callout) }
    it { is_expected.to have_many(:callout_participations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:contacts) }

    describe "#run!" do
      it "populates the callout" do
        callout_population = create(:callout_population)
        contact = create(:contact, account: callout_population.account)
        already_participating_contact = create(:contact, account: callout_population.account)
        create(:callout_participation, contact: already_participating_contact,
                                       callout: callout_population.callout)
        _other_contact = create(:contact)

        callout_population.run!

        expect(callout_population.callout_participations.count).to eq(1)
        callout_participation = callout_population.callout_participations.first
        expect(callout_participation.contact).to eq(contact)
        expect(callout_participation.phone_calls.count).to eq(1)
        phone_call = callout_participation.phone_calls.first
        expect(phone_call).to have_attributes(
          contact:,
          msisdn: contact.msisdn,
          callout_participation:,
          callout: callout_population.callout,
          call_flow_logic: callout_participation.call_flow_logic,
          account: callout_population.account,
          status: :created
        )
      end

      it "handles multiple runs" do
        callout = create(:callout)
        callout_population = create(:callout_population, callout:)
        contact = create(:contact, account: callout_population.account)
        create(:callout_participation, contact:, callout:, callout_population:)

        callout_population.run!
        callout_population.run!

        expect(callout_population.callout_participations.count).to eq(1)
        callout_participation = callout_population.callout_participations.first
        expect(callout_participation.phone_calls.count).to eq(1)
      end
    end

    describe "#contact_filter_metadata" do
      it "sets the contact filter metadata in the parameters attribute" do
        callout_population = CalloutPopulation.new
        callout_population.contact_filter_metadata = { "gender" => "m" }

        expect(callout_population.contact_filter_metadata).to eq("gender" => "m")
        expect(callout_population.parameters).to eq(
          "contact_filter_params" => { "metadata" => { "gender" => "m" } }
        )
      end
    end

    describe "#parameters" do
      it "sets the parameters from the account settings" do
        account = create(
          :account,
          settings: {
            "batch_operation_callout_population_parameters" => {
              "contact_filter_params" => {
                "metadata" => { "2019" => true }
              }
            }
          }
        )
        batch_operation = build(
          :callout_population,
          account:,
          parameters: {
            "contact_filter_params" => {
              "metadata" => { "gender" => "female" }
            }
          }
        )

        batch_operation.save!

        expect(batch_operation.parameters).to include(
          "contact_filter_params" => {
            "metadata" => {
              "2019" => true,
              "gender" => "female"
            }
          }
        )
      end
    end
  end
end
