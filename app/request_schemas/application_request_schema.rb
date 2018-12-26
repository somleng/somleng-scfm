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
    PhoneNumberModel.new(phone_number: value).valid?
  end

  def call_flow_logic?(value)
    CallFlowLogicModel.new(call_flow_logic: value).valid?
  end

  def remote_request_params?(value)
    RemoteRequestParamsModel.new(remote_request_params: value).valid?
  end

  class PhoneNumberModel
    include ActiveModel::Model

    attr_accessor :phone_number

    validates :phone_number, phony_plausible: true
  end

  class CallFlowLogicModel
    include ActiveModel::Model

    attr_accessor :call_flow_logic

    validates :call_flow_logic, call_flow_logic: true
  end

  class RemoteRequestParamsModel
    include ActiveModel::Model

    attr_accessor :remote_request_params

    validates :remote_request_params, twilio_request_params: true
  end

  module Types
    include Dry::Types.module

    PhoneNumber = String.constructor do |phone_number|
      PhonyRails.normalize_number(phone_number)
    end
  end
end
