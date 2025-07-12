class RepositorySettingsController < ApplicationController
  def index
    @repositories = RepoRegistry.repo_db.all
  end

  def create
    repo_url = params[:repo_url]
    repo_resolver = Repo::RepoResolverService.new(RepoRegistry.resolvers)
    result = repo_resolver.resolve(repo_url)

    if result.unknown?
      redirect_to repository_settings_path, alert: t('.invalid_repo', url: repo_url) and return
    end

    redirect_to repository_settings_path, notice: t('.repo_added', type: result.type.to_s)
  end

  def update
    domain = params[:domain]
    repo = RepoRegistry.repo_db.get(domain)
    unless repo
      redirect_to repository_settings_path, alert: t('.repo_not_found', domain: domain) and return
    end

    metadata = params.fetch(:metadata, {}).permit!.to_h
    RepoRegistry.repo_db.update(domain, metadata: metadata)
    redirect_to repository_settings_path, notice: t('.repo_updated', domain: domain)
  end
end
