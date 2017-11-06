class ApplicationFilter
  attr_accessor :options, :params

  def initialize(options = {}, params = {})
    self.options = options
    self.params = params
  end

  def resources
    association_chain.where(filter_params).metadata_has_values(metadata)
  end

  private

  def filter_params
    {}
  end

  def association_chain
    options[:association_chain]
  end

  def metadata
    params["metadata"] || {}
  end
end
