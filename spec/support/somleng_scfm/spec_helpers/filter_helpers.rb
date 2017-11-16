module SomlengScfm::SpecHelpers::FilterHelpers
  def subject
    @subject ||= described_class.new(filter_options, filter_params)
  end

  def filter_options
    @filter_options ||= {
      :association_chain => association_chain
    }
  end

  def filter_params
    @filter_params ||= {}
  end

  def json_data
    {"foo" => "bar", "bar" => "foo"}
  end
end

