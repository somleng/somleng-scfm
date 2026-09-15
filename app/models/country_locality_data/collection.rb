module CountryLocalityData
  class Collection
    include Enumerable

    def initialize
      @data = {}
    end

    def each(&)
      data.each_value(&)
    end

    def add(item)
      data[item.path] = item
    end

    def subdivisions_of(parent_path)
      select { it.path.size > parent_path.size && it.path.take(parent_path.size) == parent_path }
    end

    def to_tree(children_as: :children, &)
      nodes_by_path = {}

      sort_by { it.path.size }.each_with_object([]) do |locality, roots|
        node = yield(locality)
        nodes_by_path[locality.path] = node

        parent_path = locality.path.take(locality.path.size - 1)
        parent = nodes_by_path[parent_path]

        if parent
          parent.fetch(children_as) << node
        else
          roots << node
        end
      end
    end

    private

    attr_reader :data
  end
end
