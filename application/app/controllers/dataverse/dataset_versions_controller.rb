class Dataverse::DatasetVersionsController < ApplicationController
  include LoggingCommon

  before_action :build_dataset_url

  def versions
    validate_dataset_url(@dataset_url.dataverse_url)
    repo_info = RepoRegistry.repo_db.get(@dataset_url.dataverse_url)
    api_key = repo_info&.metadata&.auth_key
    service = Dataverse::DatasetService.new(@dataset_url.dataverse_url, api_key: api_key)

    versions_response = service.dataset_versions_by_persistent_id(@dataset_url.dataset_id)
    @versions = versions_response&.versions || []

    render partial: '/dataverse/datasets/versions', layout: false
  end

  private

  def build_dataset_url
    domain = params[:dv_hostname]
    scheme = params[:dv_scheme] || "https"
    port = params[:dv_port] || 443
    persistent_id = params[:persistent_id]
    @dataset_url = Dataverse::DataverseUrl.dataset_from_parts(domain, persistent_id, scheme: scheme, port: port)
  end

  def validate_dataset_url(dataset_url)
    resolver = Repo::RepoResolverService.new(RepoRegistry.resolvers)
    result = resolver.resolve(dataset_url)
    unless result.type == ConnectorType::DATAVERSE
      redirect_to root_path, alert: t('dataverse.datasets.url_not_supported', dataverse_url: @dataverse_url)
      return
    end
  end

end
