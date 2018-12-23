class ApplicationRequestSchema < Dry::Validation::Schema
  class_attribute :metadata_merge_modes, default: %w[replace merge deep_merge]

  configure do |config|
    config.messages = :i18n
    config.type_specs = true

    option :action, String

    def create?(_value)
      action == "create"
    end
  end

  def phone_number?(value)
    PhoneNumberValidator.new(phone_number: value).valid?
  end

  class PhoneNumberValidator
    include ActiveModel::Model

    attr_accessor :phone_number

    validates :phone_number, phony_plausible: true
  end

  module Types
    include Dry::Types.module

    PhoneNumber = String.constructor do |phone_number|
      PhonyRails.normalize_number(phone_number)
    end
  end
end
