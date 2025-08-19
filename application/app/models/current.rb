class Current < ActiveSupport::CurrentAttributes
  PERSISTED_ATTRIBUTES = %i[selected_project].freeze
  attribute :settings, *PERSISTED_ATTRIBUTES
end
