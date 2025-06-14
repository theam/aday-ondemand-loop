module Dataverse
  class DataverseHub
    include LoggingCommon
    DEFAULT_CACHE_EXPIRY = 24.hours.freeze
    HUB_API_URL = 'https://hub.dataverse.org/api/installation'

    def initialize(
      url: HUB_API_URL,
      http_client: Common::HttpClient.new(base_url: HUB_API_URL),
      expires_in: DEFAULT_CACHE_EXPIRY
    )
      @url = url
      @http_client = http_client
      @expires_in = expires_in
      @installations = []
      @last_fetched_at = nil
    end

    def installations
      if cache_expired?
        log_info('Fetching Dataverse Hub installations...', { url: @url })
        result = fetch_installations
        if result.present?
          @installations = result
          @last_fetched_at = Time.current
        end
      end

      @installations
    end

    private

    def cache_expired?
      @last_fetched_at.nil? || Time.current - @last_fetched_at > @expires_in
    end

    private

    def fetch_installations
      response = @http_client.get(@url)
      if response.success?
        json = JSON.parse(response.body)
        installations = json.map do |entry|
          {
            id: entry['dvHubId'],
            name: entry['name'],
            hostname: entry['hostname'],
          }
        end.compact

        log_info('Completed loading Dataverse installations', {servers: installations.size})
        installations
      else
        log_error('Failed to fetch Dataverse Hub data', {url: @url, response: response.status}, nil)
        []
      end
    rescue => e
      log_error('Error fetching Dataverse Hub data', {url: @url}, e)
      []
    end
  end
end
