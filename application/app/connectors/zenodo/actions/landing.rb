module Zenodo::Actions
  class Landing
    include LoggingCommon

    def show(request_params)
      query = request_params[:query]
      page = request_params[:page]&.to_i || 1
      repo_url = request_params[:repo_url]
      results = nil

      if query.present?
        service = Zenodo::SearchService.new(repo_url.server_url)
        results = service.search(query, page: page)
      end
      ConnectorResult.new(
        template: '/connectors/zenodo/landing/index',
        locals: { query: query, results: results, page: page, repo_url: repo_url },
        success: true
      )
    end
  end
end
