# frozen_string_literal: true

class EventType
  TYPES = %w[
    generic
    download_file_created
    download_file_status_changed
    download_file_message_logged
    project_created
    project_updated
  ].freeze

  private_class_method :new

  def self.get(value)
    value = value.to_s
    raise ArgumentError, "Invalid type: #{value}" unless TYPES.include?(value)

    const_get(value.upcase)
  end

  def initialize(value)
    @value = value
  end

  def to_s
    @value
  end

  TYPES.each do |type|
    const_set(type.upcase, new(type))
  end
end
