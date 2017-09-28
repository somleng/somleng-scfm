RSpec.shared_examples_for "has_metadata" do
  describe "#metadata" do
    def assert_metadata!
      expect(subject.metadata).to eq({})
    end

    it { assert_metadata! }
  end

  describe ".metadata_has_value(key, value)" do
    let(:key) { "foo" }
    let(:value) { "bar" }
    let(:metadata) { { key => value } }
    let(:results) { described_class.metadata_has_value(key, value) }
    let(:asserted_result) { create(factory, :metadata => metadata) }

    before do
      setup_scenario
    end

    def setup_scenario
      create(factory, :metadata => {"foo" => "baz"})
      asserted_result
    end

    def assert_scope!
      expect(results).to match_array([asserted_result])
    end

    it { assert_scope! }
  end
end
