require "rails_helper"

RSpec.describe KeyValueFieldsFor do
  class Foo
    attr_accessor :bar
    include KeyValueFieldsFor
    accepts_nested_key_value_fields_for :bar
  end

  subject { Foo.new }

  describe "#\#\{attribute_name\}_fields" do
    it "returns key value fields" do
      subject.bar = { "address" => { "city" => "pp" } }

      fields = subject.bar_fields

      expect(fields.first.key).to eq "address:city"
      expect(fields.first.value).to eq "pp"
    end
  end

  describe "#\#\{attribute_name\}_fields_attributes=" do
    it "sets a hash from key value fields" do
      attributes = { "0" => { "key" => "title", "value" => "call 1" } }

      subject.bar_fields_attributes = attributes

      expect(subject.bar).to eq("title" => "call 1")
    end
  end

  describe "#build_\#{attribute_name\}_field" do
    it "builds a new key value field" do
      result = subject.build_bar_field

      # method must return a new KeyValueField
      expect(result).to be_a(KeyValueField)
      expect(subject.bar_fields.size).to eq(1)
      expect(subject.bar_fields[0]).to be_a(KeyValueField)
    end
  end

  describe "#rejectable_\#{attribute_name\}_fields" do
    it { expect(subject.rejectable_bar_fields).to eq([]) }
  end
end
