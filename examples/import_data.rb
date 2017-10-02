#!/usr/bin/env ruby

class MyImporter
  def import!
    header_row = rows.shift if has_header_row?
    rows.each_with_index do |row, index|
      create_phone_number(
        row[4],
        "distribution_area" => row[0],
        "household_name" => row[1],
        "recipient_name" => row[2],
        "recipient_location" => row[3],
        "household_size" => row[5],
        "document_number" => row[6],
        "token_number" => row[7],
        "transfer_value" => row[8],
        "implementing_partner" => row[9],
        "scope_district" => row[10],
        "person_hh_role" => row[12],
        "date_registered" => row[13],
        "gender" => row[14],
        "address" => row[15],
        "location" => row[16],
        "district" => row[17],
        "age" => row[18],
        "average_hh_age" => row[20],
        "no_hh_females" => row[21],
        "no_hh_males" => row[22]
      )

      print_import_summary(index + 1) if ((index + 1 % 1000) == 0)
    end

    print_import_summary(rows.count)
  end

  private

  def print_import_summary(rows_completed = nil)
    puts "#{rows_completed}/#{rows.count} rows read, #{PhoneNumber.count} phone numbers created"
  end

  def callout
    @callout ||= Callout.first || Callout.create!
  end

  def create_phone_number(msisdn, metadata = {})
    callout.phone_numbers.create(
      :msisdn => msisdn,
      :metadata => metadata
    )
  end

  def rows
    load_file
  end

  def load_file
    @load_file ||= CSV.read(import_file)
  end

  def import_file
    ENV["IMPORT_FILE"]
  end

  def has_header_row?
    ENV["HEADER_ROW"].to_i == 1
  end
end

importer = MyImporter.new
importer.import!
