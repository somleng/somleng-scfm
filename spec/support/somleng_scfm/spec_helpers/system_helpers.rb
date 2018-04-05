require_relative "../spec_helpers"

module SomlengScfm::SpecHelpers::SystemHelpers
  def have_record(record)
    name = record.class.name.downcase
    have_selector("##{name}_#{record.id}")
  end
end
