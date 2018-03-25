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

    describe 'valid_metadata_forms' do
      subject { create(factory, :metadata => {}) }

      context 'when has invalid metadata_forms' do
        it 'should not valid and return false' do
          invalid_metadata_form = MetadataForm.new(attr_key: 'contact:name')
          subject.metadata_forms = [invalid_metadata_form]

          expect(subject.valid?(:dashboard)).to eq(false)
          expect(subject.errors[:base]).to include('invalid metadata')
        end
      end
    end
  end

  describe '#metadata_forms' do
    subject { create(factory, metadata: {}) }

    it 'return new metadata form when metadata empty' do
      new_metadata_form = MetadataForm.new
      allow(MetadataForm).to receive(:new).and_return(new_metadata_form)
      expect(subject.metadata_forms).to eq([new_metadata_form])
    end

    it 'return unested data as metadata_form object' do
      subject.metadata = { 'address' => { 'city' => 'pp' }}

      metadata_form = subject.metadata_forms.first

      expect(metadata_form.attr_key).to eq 'address:city'
      expect(metadata_form.attr_val).to eq 'pp'
    end
  end

  describe '#metadata_forms_attributes=(attributes)' do
    subject { create(factory, :metadata => {}) }

    it 'should build new metadata_form and assign to metadata' do
      attributes = {"0"=>{"attr_key"=>"title", "attr_val"=>"call 1"}}

      subject.metadata_forms_attributes=(attributes)
      expect(subject.metadata).to eq({ 'title' => 'call 1'})
    end
  end

  describe "#metadata" do
    subject { create(factory, :metadata => {}) }
    it { expect(subject.metadata).to eq({}) }
  end

  describe "#metadata=(value)" do
    let(:existing_metadata) { {"a" => "b", "foo" => "bar", "baz" => {"c" => [1, 2, 3] }} }
    let(:new_metadata) { { "foo" => "baz", "bar" => "baz", "baz" => {"x" => [4, 5, 6] }} }
    let(:metadata_merge_mode) { nil }

    subject {
      build(
        factory,
        :metadata_merge_mode => metadata_merge_mode,
        :metadata => existing_metadata
      )
    }

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
