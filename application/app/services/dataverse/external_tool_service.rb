module Dataverse
  class ExternalToolService
    include LoggingCommon
    def initialize(http_client: Common::HttpClient.new)
      @http_client = http_client
    end

    def process_callback(callback)
      decoded = Base64.decode64(callback)
      parsed_url = URI.parse(decoded)

      raise ArgumentError, 'Invalid callback URL' unless valid_callback_url?(parsed_url)

      log_info("requesting #{parsed_url}", { parsed_url: parsed_url })
      response = @http_client.get(parsed_url)
      external_tool_response = response.success? ? ExternalToolResponse.new(response.body) : nil

      dataverse_url = URI::Generic.build(scheme: parsed_url.scheme, host: parsed_url.hostname, port: parsed_url.port)

      {
        response: external_tool_response,
        dataverse_uri: dataverse_url,
      }
    end

    private

    def valid_callback_url?(uri)
      return false unless uri.scheme =~ /^https?$/
      return false if uri.host.nil? || uri.host.empty?

      uri.path.start_with?('/api/') || uri.path.start_with?('/external/')
    end
  end
end