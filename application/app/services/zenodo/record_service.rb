module Zenodo
  class RecordService
    include LoggingCommon

    def initialize(zenodo_url = 'https://zenodo.org', http_client: Common::HttpClient.new(base_url: zenodo_url))
      @zenodo_url = zenodo_url
      @http_client = http_client
    end

    def find_record(record_id)
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('records')
              .add_path(record_id)
              .to_s
      response = @http_client.get(url)
      return nil unless response.success?
      RecordResponse.new(response.body)
    end

    def get_or_create_deposition(record_id, api_key:)
      headers = { 'Content-Type' => 'application/json', ApiService::AUTH_HEADER => "Bearer #{api_key}" }
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('records')
              .add_path(record_id)
              .add_path('draft')
              .to_s
      response = @http_client.post(url, headers: headers)

      return nil if response.not_found?
      raise ApiService::UnauthorizedException if response.unauthorized?
      raise "Error retrieving deposition: #{response.status} - #{response.body}" unless response.success?

      DepositionResponse.new(response.body)
    end
  end
end
