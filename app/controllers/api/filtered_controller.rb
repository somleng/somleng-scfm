class Api::FilteredController < Api::AuthenticatedController
  include Rails::Pagination
  respond_to :json

  def index
    find_resources
    respond_with_resources
  end

  private

  def find_resources
    @resources = find_filtered_resources
  end

  def respond_with_resources
    respond_with(paginated_resources)
  end

  def paginated_resources
    paginate(resources)
  end

  def find_filtered_resources
    if filter_class
      filter_class.new(filter_options, filter_params).resources
    else
      find_resources_association_chain
    end
  end

  def find_resources_association_chain
    association_chain
  end

  def filter_params
    permitted_query_params[:q] || {}
  end

  def permitted_query_params
    params.permit(:q => {})
  end

  def filter_class
  end

  def filter_options
    {:association_chain => find_resources_association_chain}
  end
end
