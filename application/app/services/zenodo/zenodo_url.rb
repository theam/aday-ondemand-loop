module Zenodo
  class ZenodoUrl
    attr_reader :domain, :record_id, :type

    TYPES = %w[record unknown].freeze

    def self.parse(url)
      base = UrlParser.parse(url)
      return nil unless base
      new(base)
    end

    private_class_method :new

    TYPES.each do |t|
      define_method("#{t}?") { type == t }
    end

    def scheme_override
      'http' unless @base.https?
    end

    def port
      @base.port
    end

    def initialize(base)
      @base = base
      @domain = base.domain
      parse_type_and_ids
    end

    private

    def parse_type_and_ids
      segments = @base.path_segments
      if segments.length >= 2 && segments[0] == 'record'
        @type = 'record'
        @record_id = segments[1]
      else
        @type = 'unknown'
      end
    end
  end
end
