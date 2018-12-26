module Rails6Backports
  extend ActiveSupport::Concern

  class_methods do
    def create_or_find_by!(attributes, &block)
      transaction(requires_new: true) { create!(attributes, &block) }
    rescue ActiveRecord::RecordNotUnique
      find_by!(attributes)
    end
  end
end
