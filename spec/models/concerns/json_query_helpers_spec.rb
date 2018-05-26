require 'rails_helper'

RSpec.describe JsonQueryHelpers do
  let(:model) { Contact }
  let(:model_factory) { :contact }
  let(:json_column) { :metadata }

  describe ".json_has_value" do
    it "matches nil value" do
      nil_record = create_record_with_json("foo": nil)
      _bar_record = create_record_with_json("foo": "bar")

      results = model.json_has_value("foo", nil, json_column)

      expect(results).to match_array([nil_record])
    end

    it "matches single value" do
      bar_record = create_record_with_json("foo": "bar")
      _baz_record = create_record_with_json("foo": "baz")

      results = model.json_has_value("foo", "bar", json_column)

      expect(results).to match_array([bar_record])
    end

    it "matches multiple values" do
      bar_record = create_record_with_json("foo": "bar")
      baz_record = create_record_with_json("foo": "baz")
      _not_match_record = create_record_with_json("foo": "not_match")

      results = model.json_has_value("foo", %w[bar baz], json_column)

      expect(results).to match_array([bar_record, baz_record])
    end
  end

  def create_record_with_json(attributes = {})
    create(model_factory, json_column => attributes)
  end
end
