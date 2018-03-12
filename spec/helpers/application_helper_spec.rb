require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#flash_class' do
    it 'returns flash alert class name based on given type' do
      expect(helper.flash_class('notice')).to eq 'alert alert-info'
      expect(helper.flash_class('success')).to eq 'alert alert-success'
      expect(helper.flash_class('error')).to eq 'alert alert-danger'
      expect(helper.flash_class('alert')).to eq 'alert alert-danger'
    end
  end
end
