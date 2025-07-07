module Dataverse::Concerns::DataverseUrlBuilder
  extend ActiveSupport::Concern

  def collection_url
    raise 'collection_id is missing' unless collection_id
    base = URI(dataverse_url)
    URI.join(base.to_s + '/', "dataverse/#{collection_id}").to_s
  end

  def dataset_url(version: nil)
    raise 'dataset_id (DOI) is missing' unless dataset_id
    base = URI(dataverse_url)
    uri = URI.join(base.to_s + '/', 'dataset.xhtml')
    params = { persistentId: dataset_id }
    params[:version] = version if version
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end