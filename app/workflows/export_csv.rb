require "csv"

class ExportCSV < ApplicationWorkflow
  attr_reader :export

  def initialize(export)
    super()
    @export = export
  end

  def call
    Tempfile.open do |tmpfile|
      write_csv(tmpfile)
      attach_file(tmpfile)
    end
  end

  private

  def write_csv(file)
    CSV.open(file, "w") do |csv|
      csv << attribute_names

      ApplicationRecord.uncached do
        total_records = records.count
        records.find_each.with_index do |record, index|
          progress_percentage = (index + 1) * 100 / total_records
          export.update!(progress_percentage:) if (index % 500).zero?

          csv << serializer_class.new(record.decorated).as_csv
        end

        export.update!(completed_at: Time.current, progress_percentage: 100)
      end
    end
  end

  def attach_file(csv)
    export.file.attach(
      io: csv,
      filename: export.name,
      content_type: "text/csv"
    )
  end

  def records
    FilterScope.new(
      scope: resources_scope,
      filter_group: filter_class.new(input_params: export.filter_params).output
    ).apply
  end

  def attribute_names
    serializer_class.new(resource_class.new).headers
  end

  def serializer_class
    @serializer_class ||= resource_class.csv_serializer_class
  end

  def resources_scope
    resource_class.where(export.scoped_to).includes(serializer_class.associations)
  end

  def resource_class
    export.resource_type.constantize
  end

  def filter_class
    "#{resource_class}Filter".constantize
  end
end
