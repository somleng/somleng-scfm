module CustomRoutesHelper
  def self.[](route_key)
    Module.new do
      extend ActiveSupport::Concern

      included do
        model_name.define_singleton_method(:route_key) { route_key }
        model_name.define_singleton_method(:singular_route_key) { route_key.singularize }
      end
    end
  end
end
