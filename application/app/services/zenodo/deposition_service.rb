# frozen_string_literal: true

module Zenodo
  class DepositionService < Zenodo::ApiService
    def initialize(zenodo_url, http_client: Common::HttpClient.new(base_url: zenodo_url), api_key:)
      @zenodo_url = zenodo_url
      @http_client = http_client
      @api_key = api_key
    end

    def create_deposition(request)
      raise ApiKeyRequiredException unless @api_key

      headers = { 'Content-Type' => 'application/json', AUTH_HEADER => "Bearer #{@api_key}" }
      body = { metadata: request.to_h }

      response = @http_client.post('/api/deposit/depositions', body: body.to_json, headers: headers)

      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error creating deposition: #{response.status} - #{response.body}" unless response.success?

      Zenodo::CreateDepositionResponse.new(response.body)
    end
  end
end
