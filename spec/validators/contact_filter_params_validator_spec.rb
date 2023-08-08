require "rails_helper"

RSpec.describe ContactFilterParamsValidator do
  it "validates the contact filter params are valid" do
    validatable_klass = Struct.new(:contact_filter_params, keyword_init: true) do
      include ActiveModel::Validations

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      validates :contact_filter_params, contact_filter_params: true
    end

    valid_model = validatable_klass.new(
      contact_filter_params: {
        metadata: { "date_of_birth.date.gteq" => "2022-01-01" }
      }
    )
    invalid_model = validatable_klass.new(
      contact_filter_params: {
        metadata: { "date_of_birth.data.gteq" => "2022-01-01" }
      }
    )

    expect(valid_model.valid?).to eq(true)

    expect(invalid_model.valid?).to eq(false)
    expect(invalid_model.errors[:contact_filter_params]).to be_present
  end
end
