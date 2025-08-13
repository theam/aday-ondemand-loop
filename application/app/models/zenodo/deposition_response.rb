# frozen_string_literal: true

require_relative 'deposition'

module Zenodo
  class DepositionResponse < Deposition
    def initialize(response_body)
      super(JSON.parse(response_body))
    end
  end
end
