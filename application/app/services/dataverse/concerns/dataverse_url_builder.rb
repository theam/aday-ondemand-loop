module Dataverse::Concerns::DataverseUrlBuilder
  extend ActiveSupport::Concern

  # Module-level helpers to build URLs from components
  def collection_url(dataverse_url, id)
    FluentUrl.new(dataverse_url)
      .add_path('dataverse')
      .add_path(id)
      .to_s
  end
  module_function :collection_url

  def dataset_url(dataverse_url, id, version: nil)
    url = FluentUrl.new(dataverse_url)
              .add_path('dataset.xhtml')
              .add_param('persistentId', id)
    url.add_param('version', version) if version
    url.to_s
  end
  module_function :dataset_url

  included do
    def collection_url(id = nil)
      id ||= respond_to?(:collection_id) ? collection_id : nil
      raise 'collection_id is missing' unless id
      Dataverse::Concerns::DataverseUrlBuilder.collection_url(dataverse_url, id)
    end

    def dataset_url(id = nil, version: nil)
      id ||= respond_to?(:dataset_id) ? dataset_id : nil
      raise 'dataset_id (DOI) is missing' unless id
      Dataverse::Concerns::DataverseUrlBuilder.dataset_url(dataverse_url, id, version: version)
    end
  end
end
