module Zenodo
  class RecordService < Zenodo::ApiService
    DEFAULT_API_URL = 'https://zenodo.org/api'

    def initialize(api_url = DEFAULT_API_URL, http_client: Common::HttpClient.new(base_url: api_url), access_token: nil)
      @api_url = api_url
      @http_client = http_client
      @access_token = access_token
    end

    def find_record(id)
      url = "/records/#{id}"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise "Error getting record: #{response.status} - #{response.body}" unless response.success?
      RecordResponse.new(response.body)
    end

    def search_records(query, page: 1, per_page: 10)
      url = "/records?q=#{CGI.escape(query)}&page=#{page}&size=#{per_page}"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise "Error searching records: #{response.status} - #{response.body}" unless response.success?
      SearchResponse.new(response.body, page, per_page)
    end
  end
end
