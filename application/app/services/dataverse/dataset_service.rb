module Dataverse
  class DatasetService < Dataverse::ApiService

    def initialize(dataverse_url, http_client: Common::HttpClient.new(base_url: dataverse_url), api_key: nil)
      @dataverse_url = dataverse_url
      @http_client = http_client
      @api_key = api_key
    end

    def create_dataset(dataverse_id, dataset_data)
      raise ApiKeyRequiredException unless @api_key

      headers = { 'Content-Type' => 'application/json', AUTH_HEADER => @api_key }
      path = "/api/dataverses/#{URI.encode_www_form_component(dataverse_id)}/datasets"
      url = URI::Generic.build(path: path).to_s
      response = @http_client.post(url, body: dataset_data.to_body, headers: headers)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error creating dataset: #{response.status} - #{response.body}" unless response.success?
      CreateDatasetResponse.new(response.body)
    end

    def find_dataset_version_by_persistent_id(persistent_id, version: ':latest-published')
      path = "/api/datasets/:persistentId/versions/#{URI.encode_www_form_component(version) }"
      query_params = {
        persistentId: persistent_id,
        returnOwners: true,
        excludeFiles: true
      }
      url = URI::Generic.build(path: path, query: URI.encode_www_form(query_params)).to_s
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataset: #{response.status} - #{response.body}" unless response.success?
      DatasetVersionResponse.new(response.body)
    end

    def search_dataset_files_by_persistent_id(persistent_id, version: ':latest-published', page: 1, per_page: 10, query: nil)
      url = SearchDatasetFilesUrlBuilder.new(
        persistent_id: persistent_id,
        version: version,
        page: page,
        per_page: per_page,
        query: query,
      ).build
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataset files: #{response.status} - #{response.body}" unless response.success?
      DatasetFilesResponse.new(response.body, page: page, per_page: per_page, query: query)
    end
  end
end