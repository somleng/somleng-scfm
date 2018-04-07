require 'rails_helper'

RSpec.describe MetadataForm do
  describe 'validates' do
    context 'if attr_val presents' do
      subject { MetadataForm.new(attr_val: 'Group 1') }
      it { is_expected.to validate_presence_of(:attr_key) }
    end
  end

  describe '#to_json' do
    it 'should combine attr_key and attr_val to a hash' do
      metadata_form = MetadataForm.new(attr_key: 'address:city', attr_val: 'Phnom Penh')

      result = metadata_form.to_json

      expect(result).to eq({'address'=>{'city' => 'Phnom Penh'}})
    end
  end

  describe '.unnest' do
    it 'should unnested nested hash to single layout hash' do
      hash = { 'address'=> { 'city' => 'Phnom Penh' }}

      result = MetadataForm.unnest(hash)

      expect(result).to eq({ 'address:city' => 'Phnom Penh' })
    end
  end
end
