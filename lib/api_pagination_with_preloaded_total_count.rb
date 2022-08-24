module APIPaginationWithPreloadedTotalCount
  def paginate_with_kaminari(collection, options, paginate_array_options = {})
    collection, arg = super
    if paginate_array_options[:total_count]
      collection.instance_variable_set(:@total_count, paginate_array_options[:total_count])
    end
    [collection, arg]
  end
end

ApiPagination.singleton_class.prepend(APIPaginationWithPreloadedTotalCount)
