#!/usr/bin/env ruby

class MyImporter
  DEFAULT_DUMMY_CONTACT_MSISDN = "+85512234567"

  def import!
    dummy_import
  end

  private

  def dummy_import
    create_contact(dummy_contact_msisdn, :name => "Joe Blogs")
  end

  def dummy_contact_msisdn
    ENV["DUMMY_CONTACT_MSISDN"].presence || DEFAULT_DUMMY_CONTACT_MSISDN
  end

  def create_contact(msisdn, metadata = {})
    Contact.create(
      :msisdn => msisdn,
      :metadata => metadata
    )
  end
end

importer = MyImporter.new
importer.import!
