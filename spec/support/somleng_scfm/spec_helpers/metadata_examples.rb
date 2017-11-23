RSpec.shared_examples_for "has_metadata" do
  describe "validations" do
    subject { build(factory) }

    def assert_validations!
      is_expected.not_to allow_value("foo").for(:metadata)
      is_expected.to allow_value({"foo" => "bar"}).for(:metadata)
      subject.metadata = nil
      is_expected.not_to be_valid
      expect(subject.errors[:metadata]).not_to be_empty
    end

    it { assert_validations! }
  end

  describe "#metadata" do
    subject { create(factory, :metadata => {}) }
    it { expect(subject.metadata).to eq({}) }
  end

  describe ".metadata_has_value(key, value)" do
    let(:metadata_key) { "foo" }
    let(:metadata_value) { "bar" }
    let(:metadata) { { metadata_key => metadata_value } }

    let(:key) { metadata_key }
    let(:value) { metadata_value }
    let(:results) { described_class.metadata_has_value(key, value) }

    let(:record_with_metadata) { create(factory, :metadata => metadata) }
    let(:record_without_metadata) { create(factory) }

    def setup_scenario
      record_with_metadata
      record_without_metadata
    end

    def assert_scope!
      expect(results).to match_array(asserted_results)
    end

    context "passing a key and value matching existing metadata" do
      let(:asserted_results) { [record_with_metadata] }
      it { assert_scope! }
    end

    context "passing nil as the value" do
      let(:value) { nil }

      context "where the key exists (but it's value is nil)" do
        let(:metadata_value) { nil }
        let(:asserted_results) { [record_with_metadata, record_without_metadata] }

        it { assert_scope! }
      end

      context "where the key does not exist" do
        let(:asserted_results) { [record_without_metadata] }
        it { assert_scope! }
      end
    end
  end
end
