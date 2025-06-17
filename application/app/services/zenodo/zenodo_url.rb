module Zenodo
  class ZenodoUrl
    attr_reader :record_id

    def self.parse(url)
      uri = URI.parse(url) rescue nil
      return new(nil) unless uri
      match = uri.path.match(%r{/records/(\d+)})
      record_id = match[1] if match
      new(record_id)
    end

    def initialize(record_id)
      @record_id = record_id
    end

    def record?
      !@record_id.nil?
    end
  end
end
