class Filter::Attribute::JSON < Filter::Attribute::Base
  attr_accessor :json_params_key, :json_attribute

  def initialize(options = {}, params = {})
    self.json_attribute = options[:json_attribute]
    self.json_params_key = options[:json_params_key]
    super
  end

  def apply
    association_chain.json_has_values(json_params, json_attribute)
  end

  def apply?
    json_params.any?
  end

  private

  def json_params
    (params[json_params_key || json_attribute] || {}).to_h
  end
end
