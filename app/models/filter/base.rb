class Filter::Base
  attr_accessor :options, :params

  def initialize(options = {}, params = {})
    self.options = options
    self.params = params
  end

  def association_chain
    options[:association_chain]
  end
end
