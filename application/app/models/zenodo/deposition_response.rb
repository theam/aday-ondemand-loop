# frozen_string_literal: true

require 'forwardable'
require_relative 'deposition'

module Zenodo
  class DepositionResponse
    extend Forwardable

    attr_reader :deposition

    def_delegators :@deposition, :id, :title, :description, :publication_date,
                                     :files, :file_count, :bucket_url, :submitted,
                                     :raw, :draft?, :to_s

    def initialize(response_body)
      @deposition = Deposition.new(JSON.parse(response_body))
    end
  end
end
