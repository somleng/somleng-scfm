class MetadataForm
  include ActiveModel::Model

  attr_accessor :attr_key, :attr_val

  validates :attr_val, presence: true, if: 'attr_key.present?'
  validates :attr_key, presence: true, if: 'attr_val.present?'

  def self.unnest(hash)
    new_hash = {}
    hash.each do |key,val|
      if val.is_a?(Hash)
        new_hash.merge!(prefix_keys("#{key}:", val))
      else
        new_hash[key] = val
      end
    end
    new_hash
  end

  def to_json
    attr_key.split(':').reverse.inject(attr_val) { |v, k| { k => v }}
  end

  private

  def self.prefix_keys(prefix, hash)
    unnest(Hash[hash.map{|key,val| [prefix + key, val]}])
  end
end
