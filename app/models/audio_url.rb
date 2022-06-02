class AudioURL
  attr_reader :key, :region, :bucket

  def initialize(options)
    @key = options.fetch(:key)
    @region = options.fetch(:region, Rails.configuration.app_settings.fetch(:aws_region))
    @bucket = options.fetch(:bucket, Rails.configuration.app_settings.fetch(:audio_bucket))
  end

  def url
    "https://s3.#{region}.amazonaws.com/#{bucket}/#{key}"
  end
end
