module PumiHelpers
  extend ActiveSupport::Concern

  included do
    store_accessor :metadata, :commune_ids

    delegate :id, :name_en, :name_km, to: :province, prefix: true, allow_nil: true

    validates :commune_ids, presence: true
    before_validation :remove_empty_commune_ids
  end

  def province
    return if commune_ids.blank?
    Pumi::Province.find_by_id(commune_ids.first[0..1])
  end

  private

  def remove_empty_commune_ids
    self.commune_ids = Array(commune_ids).reject(&:blank?)
  end
end
