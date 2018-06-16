class AudioFileProcessorJob < ApplicationJob
  require "aws-sdk-s3"

  def perform(callout_id)
    callout = Callout.find(callout_id)
    bucket_object = s3_resource.bucket(audio_bucket).object(generate_object_uuid)

    open(callout.audio_file.service_url) do |f|
      bucket_object.put(body: f.read)
    end

    callout.audio_url = bucket_object.public_url
    callout.save!
  end

  private

  def audio_bucket
    Rails.application.secrets.fetch(:audio_bucket)
  end

  def generate_object_uuid
    SecureRandom.uuid
  end

  def s3_resource
    @s3_resource ||= Aws::S3::Resource.new
  end
end
