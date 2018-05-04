require_relative "../spec_helpers"

module SomlengScfm::SpecHelpers::SystemHelpers
  def have_record(record)
    name = record.class.name.downcase
    have_selector("##{name}_#{record.id}")
  end

  def include_location(name)
    location = Pumi::Province.where(name_en: name).first
    include(location.id)
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end
