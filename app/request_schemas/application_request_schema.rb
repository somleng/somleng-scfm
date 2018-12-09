class ApplicationRequestSchema < Dry::Validation::Schema
  configure do |config|
    config.messages = :i18n
    config.type_specs = true
  end
end
