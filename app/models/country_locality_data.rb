module CountryLocalityData
  class Cache
    attr_reader :data_source

    def initialize(data_source)
      @data_source = data_source
    end

    def data
      @data ||= data_source.call
    end
  end

  Configuration = Data.define(:local_language, :cache) do
    def self.blank
      new(local_language: nil, data: -> { Collection.new })
    end

    def initialize(data:, **)
      super(cache: Cache.new(data), **)
    end

    def collection
      cache.data
    end

    def to_tree(...)
      collection.to_tree(...)
    end
  end

  SETTINGS = {
    KH: Configuration.new(local_language: :km, data: -> { CountryLocalityData::Cambodia.locality_data }),
    LA: Configuration.new(local_language: :lo, data: -> { CountryLocalityData::Laos.locality_data }),
    NP: Configuration.new(local_language: :ne, data: -> { CountryLocalityData::Nepal.locality_data }),
    MM: Configuration.new(local_language: :my, data: -> { CountryLocalityData::Myanmar.locality_data })
  }

  def self.locality_data(iso_country_code)
    return Configuration.blank unless supported?(iso_country_code)

    SETTINGS.fetch(iso_country_code.to_sym)
  end

  def self.supported?(iso_country_code)
    return false if iso_country_code.blank?

    SETTINGS.key?(iso_country_code.to_sym)
  end
end
