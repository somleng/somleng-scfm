require 'rails_helper'

RSpec.describe CustomRoutesHelper do
  class Foo
    include ActiveModel::Model
    include CustomRoutesHelper["bars"]
  end

  it "customizes route keys" do
    expect(Foo.model_name.route_key).to eq("bars")
    expect(Foo.model_name.singular_route_key).to eq("bar")
  end
end
