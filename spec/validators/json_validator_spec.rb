require "rails_helper"

RSpec.describe JSONValidator do
  it "validates json" do
    validatable_klass = Struct.new(:json_attribute) do
      include ActiveModel::Validations

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      validates :json_attribute, json: true
    end

    expect(validatable_klass.new(nil).valid?).to eq(false)
    expect(validatable_klass.new("foo").valid?).to eq(false)
    expect(validatable_klass.new({}).valid?).to eq(true)
  end
end
