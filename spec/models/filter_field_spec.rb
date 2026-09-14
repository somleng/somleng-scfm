require "rails_helper"

RSpec.describe FilterField, type: :model do
  describe "#to_query" do
    it "handles `eq` operator" do
      result = FilterField.new(
        name: :gender,
        operator: "eq",
        value: "M"
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["gender"].eq("M").to_sql)
    end

    it "handles `not_eq` operator" do
      result = FilterField.new(
        name: :gender,
        operator: "not_eq",
        value: "M"
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["gender"].not_eq("M").to_sql)
    end

    it "handles `gt` operator" do
      result = FilterField.new(
        name: :date_of_birth,
        operator: "gt",
        value: Date.today
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["date_of_birth"].gt(Date.today).to_sql)
    end

    it "handles `gteq` operator" do
      result = FilterField.new(
        name: :date_of_birth,
        operator: "gteq",
        value: Date.today
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["date_of_birth"].gteq(Date.today).to_sql)
    end

    it "handles `lt` operator" do
      result = FilterField.new(
        name: :date_of_birth,
        operator: "lt",
        value: Date.today
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["date_of_birth"].lt(Date.today).to_sql)
    end

    it "handles `lteq` operator" do
      result = FilterField.new(
        name: :date_of_birth,
        operator: "lteq",
        value: Date.today
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["date_of_birth"].lteq(Date.today).to_sql)
    end

    it "handles `between` operator" do
      result = FilterField.new(
        name: :date_of_birth,
        operator: "between",
        value: [ Date.yesterday, Date.today ]
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["date_of_birth"].between(Date.yesterday..Date.today).to_sql)
    end

    it "handles `contains` operator" do
      result = FilterField.new(
        name: :iso_language_code,
        operator: "contains",
        value: "foo"
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["iso_language_code"].matches("%foo%").to_sql)
    end

    it "handles `not_contains` operator" do
      result = FilterField.new(
        name: :iso_language_code,
        operator: "not_contains",
        value: "foo"
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["iso_language_code"].does_not_match("%foo%").to_sql)
    end

    it "handles `starts_with` operator" do
      result = FilterField.new(
        name: :iso_language_code,
        operator: "starts_with",
        value: "foo"
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["iso_language_code"].matches("foo%").to_sql)
    end

    it "handles `is_null` operator" do
      result = FilterField.new(
        name: :gender,
        operator: "is_null",
        value: true
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["gender"].eq(nil).to_sql)

      result = FilterField.new(
        name: :gender,
        operator: "is_null",
        value: false
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["gender"].not_eq(nil).to_sql)
    end

    it "handles `in` operator" do
      result = FilterField.new(
        name: :gender,
        operator: "in",
        value: [ "M", "F" ]
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["gender"].in([ "M", "F" ]).to_sql)
    end

    it "handles `not_in` operator" do
      result = FilterField.new(
        name: :gender,
        operator: "not_in",
        value: [ "M", "F" ]
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["gender"].not_in([ "M", "F" ]).to_sql)
    end

    it "handles unsupported operator" do
      expect {
        FilterField.new(
          name: :gender,
          operator: "invalid-operator",
          value: "true"
        ).to_query(scope: Beneficiary)
      }.to raise_error(ArgumentError)
    end

    it "handles custom types" do
      result = FilterField.new(
        name: :phone_number,
        operator: "starts_with",
        value: "855"
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq("\"beneficiaries\".\"phone_number\" ILIKE '855%'")
    end

    it "handles SQL injection" do
      result = FilterField.new(
        name: :iso_language_code,
        operator: "starts_with",
        value: "'"
      ).to_query(scope: Beneficiary)

      expect(result.to_sql).to eq(Beneficiary.arel_table["iso_language_code"].matches("'%").to_sql)
    end
  end
end
