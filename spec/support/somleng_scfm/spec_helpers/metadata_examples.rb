RSpec.shared_examples_for "has_metadata" do
  describe "validations" do
    subject { build(factory) }

    def assert_validations!
      is_expected.to allow_value("foo" => "bar").for(:metadata)
    end

    it { assert_validations! }
  end

  describe "#metadata_fields" do
    it "returns key value fields" do
      subject = build_stubbed(factory)
      subject.metadata = { "address" => { "city" => "pp" } }

      metadata_fields = subject.metadata_fields

      expect(metadata_fields.first.key).to eq "address:city"
      expect(metadata_fields.first.value).to eq "pp"
    end
  end

  describe "#metadata_fields_attributes=(attributes)" do
    it "builds new metadata_form and assign to metadata" do
      subject = build_stubbed(factory)
      attributes = { "0" => { "key" => "title", "value" => "call 1" } }

      subject.metadata_fields_attributes = attributes

      expect(subject.metadata).to eq("title" => "call 1")
    end
  end

  describe "#build_metadata_field" do
    it "build a new key value field" do
      subject = build_stubbed(factory)

      result = subject.build_metadata_field

      # method must return a new KeyValueField
      expect(result).to be_a(KeyValueField)
      expect(subject.metadata_fields.size).to eq(1)
      expect(subject.metadata_fields[0]).to be_a(KeyValueField)
    end
  end

  describe "#metadata" do
    subject { create(factory, :metadata => {}) }
    it { expect(subject.metadata).to include({}) }
  end

  describe "#metadata=(value)" do
    let(:existing_metadata) { { "a" => "b", "foo" => "bar", "baz" => { "c" => [1, 2, 3] } } }
    let(:new_metadata) { { "foo" => "baz", "bar" => "baz", "baz" => { "x" => [4, 5, 6] } } }
    let(:metadata_merge_mode) { nil }

    subject do
      build(
        factory,
        metadata_merge_mode: metadata_merge_mode,
        metadata: existing_metadata
      )
    end

    def setup_scenario
      subject.metadata = new_metadata
    end

    context "by default" do
      let(:metadata_merge_mode) { nil }
      it { expect(subject.metadata).to eq(existing_metadata.merge(new_metadata)) }
    end

    context "metadata_merge_mode='replace'" do
      let(:metadata_merge_mode) { "replace" }
      it { expect(subject.metadata).to eq(new_metadata) }
    end

    context "metadata_merge_mode='merge'" do
      let(:metadata_merge_mode) { "merge" }
      it { expect(subject.metadata).to eq(existing_metadata.merge(new_metadata)) }
    end

    context "metadata_merge_mode='deep_merge'" do
      let(:metadata_merge_mode) { "deep_merge" }
      it { expect(subject.metadata).to eq(existing_metadata.deep_merge(new_metadata)) }
    end

    context "metadata_merge_mode='delete'" do
      let(:metadata_merge_mode) { "delete" }
      it { expect(subject.metadata).to eq(existing_metadata.merge(new_metadata)) }
    end

    context "new_metadata='foo'" do
      let(:new_metadata) { "foo" }
      it { expect(subject.metadata).to eq(new_metadata) }
    end
  end
end
