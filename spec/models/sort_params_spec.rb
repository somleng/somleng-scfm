require "rails_helper"

RSpec.describe SortParams do
  describe "#build_params" do
    it "returns an empty hash by default" do
      sort_params = described_class.new

      result = sort_params.build_params

      expect(result).to eq({})
    end

    it "returns sort params according to the json-schema recommendation" do
      sort_params = described_class.new(sort_column: :id, sort_direction: :desc)

      result = sort_params.build_params

      expect(result).to eq(sort: "-id")
    end
  end

  describe "#order_attributes" do
    it "returns default order attributes" do
      sort_params = described_class.new

      result = sort_params.order_attributes

      expect(result).to eq(SortParams::DEFAULT_ORDER_ATTRIBUTES)
    end

    it "returns order attributes according the json-schema recommendation" do
      sort_params = described_class.new(params: { sort: "-id,created_at" })

      result = sort_params.order_attributes

      expect(result).to eq(
        "id" => :desc,
        "created_at" => :asc
      )
    end
  end

  describe "#order_column" do
    it "returns the default order column by default" do
      sort_params = described_class.new

      result = sort_params.order_column

      expect(result).to eq(:id)
    end

    it "returns the first column of the sort params" do
      sort_params = described_class.new(params: { sort: "-id,created_at" })

      result = sort_params.order_column

      expect(result).to eq(:id)
    end
  end

  describe "#order_direction" do
    it "returns the default order direction by default" do
      sort_params = described_class.new

      result = sort_params.order_direction

      expect(result).to eq(SortParams::ORDER_DESCENDING)
    end

    it "returns the direction of the first column of the sort params" do
      sort_params = described_class.new(params: { sort: "id,created_at" })

      result = sort_params.order_direction

      expect(result).to eq(SortParams::ORDER_ASCENDING)
    end
  end

  describe "#toggle_order_direction" do
    it "returns opposite of the default direction by default" do
      sort_params = described_class.new

      result = sort_params.toggle_order_direction

      expect(result).to eq(SortParams::ORDER_ASCENDING)
    end

    it "returns the opposite direction of the first column of the sort params" do
      sort_params = described_class.new(params: { sort: "id,created_at" })

      result = sort_params.toggle_order_direction

      expect(result).to eq(SortParams::ORDER_DESCENDING)
    end
  end
end
