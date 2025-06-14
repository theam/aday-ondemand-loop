module Zenodo
  class SearchResponse
    include ActsAsPage
    attr_reader :total_count, :items

    def initialize(json, page = 1, per_page = 10)
      parsed = JSON.parse(json, symbolize_names: true)
      hits = parsed[:hits] || {}
      @total_count = hits[:total] || 0
      @items = (hits[:hits] || []).map { |h| SearchHit.new(h) }
      @page = page
      @per_page = per_page
    end

    def page_items
      @items
    end

    class SearchHit
      attr_reader :id, :title

      def initialize(hit)
        data = hit[:metadata] || {}
        @id = hit[:id]
        @title = data[:title]
      end
    end
  end
end
