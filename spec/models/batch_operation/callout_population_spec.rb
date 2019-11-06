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
        _other_contact = create(:contact)

        callout_population.run!

        expect(callout_population.reload.contacts).to match_array([contact])
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
        account = build_stubbed(
          :account,
          settings: {
            "batch_operation_callout_population_parameters" => {
              "contact_filter_params" => {
                "2019" => true
              }
            }
          }
        )
        batch_operation = BatchOperation::CalloutPopulation.new(
          account: account,
          parameters: {
            "contact_filter_params" => {
              "female" => true
            }
          }
        )

        batch_operation.valid?

        expect(batch_operation.parameters).to eq(
          "contact_filter_params" => { "2019" => true, "female" => true }
        )
      end
    end
  end
end
