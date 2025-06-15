class DataverseExternalToolService
    include LoggingCommon
    def initialize(http_client: Common::HttpClient.new)
      @http_client = http_client
    end

    def process_callback(callback)
      decoded = Base64.decode64(callback)
      parsed_url = URI.parse(decoded)

      log_info("requesting #{parsed_url}", { parsed_url: parsed_url })
      response = @http_client.get(parsed_url)
      external_tool_response = DataverseExternalToolResponse.new(response.body) if response.success?

      dataverse_url = URI::Generic.build(scheme: parsed_url.scheme, host: parsed_url.hostname, port: parsed_url.port)

      {
        response: external_tool_response,
        dataverse_uri: dataverse_url,
      }
    end
  end
end
