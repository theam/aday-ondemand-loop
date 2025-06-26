module Zenodo
  class SearchResponse
    include ActsAsPage
    attr_reader :items

    def initialize(json, page, per_page)
      data = JSON.parse(json)
      @page = page
      @per_page = per_page
      hits = data.fetch('hits', {})
      total = hits['total']
      @total_count = if total.is_a?(Hash)
                       total['value']
                     else
                       total || Array(hits['hits']).count
                     end
      @items = Array(hits['hits']).map do |hit|
        OpenStruct.new(id: hit['id'].to_s, title: hit.dig('metadata', 'title'))
      end
    end
  end
end
