class Current < ActiveSupport::CurrentAttributes
  PERSISTED_ATTRIBUTES = %i[from_project].freeze
  attribute :settings, *PERSISTED_ATTRIBUTES
end
