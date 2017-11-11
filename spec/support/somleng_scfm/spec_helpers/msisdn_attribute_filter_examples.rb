RSpec.shared_examples_for "msisdn_attribute_filter" do
  let(:somali_msisdn) { generate(:somali_msisdn) }
  let(:filterable) { create(filterable_factory, :msisdn => somali_msisdn) }

  def setup_scenario
    super
    filterable
  end

  context "filtering by msisdn" do
    def filter_params
      super.merge(:msisdn => msisdn)
    end

    def assert_filter!
      expect(subject.resources).to match_array(asserted_results)
    end

    context "msisdn matches" do
      let(:msisdn) { somali_msisdn }
      let(:asserted_results) { [filterable] }
      it { assert_filter! }
    end

    context "msisdn does not match" do
      let(:msisdn) { "wrong" }
      let(:asserted_results) { [] }
      it { assert_filter! }
    end
  end
end
