require "rails_helper"

module FieldDefinitions
  module FilterSchema
    RSpec.describe ArrayType do
      it "supports `eq` operator" do
        expect(validate_schema(build_schema, input: { eq: [ "foo", "bar" ] })).to be_success
        expect(validate_schema(build_schema, input: { eq: "foo" })).to be_success
        expect(validate_schema(build_schema(included_in: [ "bar" ]), input: { eq: "foo" })).not_to be_success
        expect(validate_schema(build_schema(included_in: [ "bar" ]), input: { eq: [ "foo", "bar" ] })).not_to be_success
      end

      it "supports `contains` operator" do
        expect(validate_schema(build_schema, input: { contains: [ "foo", "bar" ] })).to be_success
        expect(validate_schema(build_schema, input: { contains: "foo" })).to be_success
        expect(validate_schema(build_schema(included_in: [ "bar" ]), input: { contains: "foo" })).not_to be_success
        expect(validate_schema(build_schema(included_in: [ "bar" ]), input: { contains: [ "foo", "bar" ] })).not_to be_success
      end

      it "whitelists supported operators" do
        schema = build_schema

        expect(schema.schema_definition.key_map.map(&:name)).to contain_exactly(
          "eq",
          "contains"
        )
      end

      def validate_schema(schema, input:)
        schema.schema_definition.call(input)
      end

      def build_schema(...)
        ArrayType.define(...)
      end
    end
  end
end
