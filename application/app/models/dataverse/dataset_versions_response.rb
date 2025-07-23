module Dataverse
  class DatasetVersionsResponse
    attr_reader :status, :versions

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @versions = (parsed[:data] || []).map do |v|
        Dataverse::DatasetVersionResponse::Data.new(v)
      end
    end
  end
end
