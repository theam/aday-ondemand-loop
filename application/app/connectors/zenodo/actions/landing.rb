module Zenodo::Actions
  class Landing
    include LoggingCommon

    def show(request_params)
      query = request_params[:query]
      page = request_params[:page]&.to_i || 1
      per_page = request_params[:per_page]&.to_i || 10
      repo_url = request_params[:repo_url]
      results = nil

      begin
        if query.present?
          service = Zenodo::SearchService.new(repo_url.server_url)
          results = service.search(query, page: page, per_page: per_page)
        end
        ConnectorResult.new(
          template: '/connectors/zenodo/landing',
          locals: { query: query, results: results, page: page, per_page: per_page, repo_url: repo_url },
          success: true
        )
      rescue => e
        log_error('Search Zenodo error', { query: query, page: page }, e)
        ConnectorResult.new(
          template: '/connectors/zenodo/landing',
          locals: { query: query, results: nil, page: page, per_page: per_page, repo_url: repo_url },
          message: { alert: I18n.t('zenodo.landing_page.index.message_search_error', query: query) },
          success: false
        )
      end
    end
  end
end
