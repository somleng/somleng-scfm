class MetadataForm
  KEY_DELIMITER = ":".freeze

  include ActiveModel::Model

  attr_accessor :attr_key, :attr_val

  validates :attr_key, presence: true, if: -> { attr_val.present? }

  class Utils
    def flatten_hash(hash)
      Hash[flat_hash(hash).map { |k, v| [k.join(KEY_DELIMITER), v] }]
    end

    private

    # https://stackoverflow.com/a/23861946
    def flat_hash(h, f = [], g = {})
      return g.update(f => h) unless h.is_a? Hash
      h.each { |k, r| flat_hash(r, f + [k], g) }
      g
    end
  end

  def to_json
    attr_key.split(KEY_DELIMITER).reverse.inject(attr_val) { |v, k| { k => v } }
  end
end
