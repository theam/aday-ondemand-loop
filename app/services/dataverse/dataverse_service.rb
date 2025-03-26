module Dataverse
  class DataverseService

    def initialize(dataverse_metadata)
      @dataverse_metadata = dataverse_metadata
    end

    def find_dataset_by_id(id)
      url = @dataverse_metadata.full_hostname + "/api/datasets/#{id}"
      url = URI.parse(url)
      response = Net::HTTP.get_response(url)
      response.is_a?(Net::HTTPSuccess) ? DatasetResponse.new(response.body) : nil
    end

    def initialize_download_collection(dataset)
      DownloadCollection.new.tap do |collection|
        collection.id = DownloadCollection.generate_id
        collection.type = "dataverse"
        collection.metadata_id = @dataverse_metadata.id
        collection.name = "#{@dataverse_metadata.full_hostname} Dataverse selection from #{dataset.data.identifier}"
      end
    end
  end
end