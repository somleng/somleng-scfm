module EnvHelpers
  private

  def stub_app_config(config)
    allow(Rails.configuration.scfm).to receive(:[]).and_call_original
    allow(Rails.configuration.scfm).to receive(:fetch).and_call_original

    config.each do |key, value|
      allow(
        Rails.configuration.scfm
      ).to receive(:[]).with(key.to_s).and_return(value.present? && value.to_s)

      allow(
        Rails.configuration.scfm
      ).to receive(:fetch).with(key.to_s).and_return(value.present? && value.to_s)
    end
  end
end

RSpec.configure do |config|
  config.include(EnvHelpers)
end
