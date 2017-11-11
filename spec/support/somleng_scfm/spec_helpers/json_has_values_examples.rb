RSpec.shared_examples_for "json_has_values" do
  let(:resource) {
    create(
      factory,
      json_column => {
        :metadata => {
          :foo => {
            :bar => {
              :baz => "foo"
            }
          }
        },
        :test => :bar
      }
    )
  }

  let(:result) { described_class.public_send(scope, hash) }
  let(:asserted_results) { [resource] }

  def setup_scenario
    super
    resource
  end

  def assert_results!
    expect(result).to match_array(asserted_results)
  end

  context "filtering with deeply nested hash" do
    let(:hash) {
      {
        :metadata => {
          :foo => {
            :bar => {
              :baz => "foo"
            }
          }
        }
      }
    }

    it { assert_results! }
  end

  context "filtering with shallow hash" do
    let(:hash) {
      {
        :test => "bar"
      }
    }

    it { assert_results! }
  end

  context "not returning any results" do
    let(:hash) {
      {
        :test => "baz"
      }
    }

    let(:asserted_results) { [] }
    it { assert_results! }
  end
end
