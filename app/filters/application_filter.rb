class ApplicationFilter
  attr_accessor :options, :params

  def initialize(options = {}, params = {})
    self.options = options
    self.params = params
  end

  def resources
    scope = association_chain
    scope = scope.merge(metadata_filter.resources) if !metadata_filter.metadata.empty?
    scope.where(filter_params)
  end

  private

  def filter_params
    {}
  end

  def association_chain
    options[:association_chain]
  end

  def metadata_filter
    @metdata_filter ||= MetadataFilter.new(options, params)
  end
end
