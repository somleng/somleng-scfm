require "rails_helper"

RSpec.describe JSONQueryHelpers do
  it "matches a nil value" do
    nil_record = create_record_with_json("foo": nil)
    _bar_record = create_record_with_json("foo": "bar")

    results = Contact.json_has_value("foo", nil, :metadata)

    expect(results).to match_array([nil_record])
  end

  it "matches a single value" do
    bar_record = create_record_with_json("foo": "bar")
    numeric_record = create_record_with_json("foo": 123)
    _baz_record = create_record_with_json("foo": "baz")

    results = Contact.json_has_value("foo", "bar", :metadata)
    expect(results).to match_array([bar_record])

    results = Contact.json_has_value("foo", 123, :metadata)
    expect(results).to match_array([numeric_record])
  end

  it "matches multiple values" do
    bar_record = create_record_with_json("foo": "bar")
    baz_record = create_record_with_json("foo": "baz")
    numeric_record = create_record_with_json("foo": 123)
    _not_match_record = create_record_with_json("foo": "not_match")

    results = Contact.json_has_value("foo.in", %w[bar 123 baz], :metadata)

    expect(results).to match_array([bar_record, baz_record, numeric_record])
  end

  it "matches any values" do
    bar_record = create_record_with_json("foo": %w[bar foobar])
    baz_record = create_record_with_json("foo": ["baz"])
    _not_match_record = create_record_with_json("foo": ["not_match"])

    results = Contact.json_has_value("foo.any", %w[bar baz], :metadata)

    expect(results).to match_array([bar_record, baz_record])
  end

  it "matches dates" do
    record = create_record_with_json(details: { "date.of.birth" => "1983-01-01" })
    create_record_with_json(details: { "date.of.birth" => "1990-01-01" })

    results = Contact.json_has_value(%w[details date.of.birth.date.lteq], "1983-01-01", :metadata)

    expect(results).to match_array([record])
  end

  it "matches against multiple dates" do
    record = create_record_with_json(details: { "date.of.birth" => "1983-01-01" })
    create_record_with_json(details: { "date.of.birth" => "1983-02-01" })

    results = Contact.json_has_values(
      {
        details: {
          "date.of.birth.date.gteq" => "1983-01-01",
          "date.of.birth.date.lt" => "1983-02-01"
        }
      }, :metadata
    )

    expect(results).to match_array([record])
  end

  def create_record_with_json(attributes = {})
    create(:contact, metadata: attributes)
  end
end
