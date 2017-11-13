class Filter::Base
  attr_accessor :options, :params

  def initialize(options = {}, params = {})
    self.options = options
    self.params = params
  end

  def association_chain
    options[:association_chain]
  end

  private

  def split_filter_values(value)
    value && value.to_s.split(",").map(&:strip).reject(&:blank?)
  end
end
