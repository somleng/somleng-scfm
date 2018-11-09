RSpec.shared_examples_for "has_metadata" do
  describe "validations" do
    subject { build_stubbed(factory) }

    it { is_expected.not_to allow_value("foo").for(:metadata) }
    it { is_expected.not_to allow_value(nil).for(:metadata) }
    it { is_expected.to allow_value("foo" => "bar").for(:metadata) }
  end

  describe "#metadata=(value)" do
    let(:existing_metadata) { { "a" => "b", "foo" => "bar", "baz" => { "c" => [1, 2, 3] } } }
    let(:new_metadata) { { "foo" => "baz", "bar" => "baz", "baz" => { "x" => [4, 5, 6] } } }

    it "merges metadata by default" do
      subject = build_with_metadata(existing_metadata)

      subject.metadata = new_metadata

      expect(subject.metadata).to eq(existing_metadata.merge(new_metadata))
    end

    it "deep merges metadata if metadata_merge_mode='deep_merge'" do
      subject = build_with_metadata(existing_metadata)

      subject.metadata_merge_mode = "deep_merge"
      subject.metadata = new_metadata

      expect(subject.metadata).to eq(existing_metadata.deep_merge(new_metadata))
    end

    it "replaces metadata if metadata_merge_mode='replace'" do
      subject = build_with_metadata(existing_metadata)

      subject.metadata_merge_mode = "replace"
      subject.metadata = new_metadata

      expect(subject.metadata).to eq(new_metadata)
    end

    it "merges metadata if metadata_merge_mode is invalid" do
      subject = build_with_metadata(existing_metadata)

      subject.metadata_merge_mode = "foo"
      subject.metadata = new_metadata

      expect(subject.metadata).to eq(existing_metadata.merge(new_metadata))
    end
  end

  def build_with_metadata(metadata)
    build_stubbed(factory, metadata: metadata)
  end
end
