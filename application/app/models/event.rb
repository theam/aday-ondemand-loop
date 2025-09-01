class Event
  include ActiveModel::Model

  ATTRIBUTES = %w[id project_id message entity_type entity_id creation_date metadata].freeze

  attr_accessor(*ATTRIBUTES)

  validates_presence_of :id, :project_id, :message, :entity_type, :creation_date

  def initialize(attributes = {})
    super
    self.id = SecureRandom.uuid.to_s if id.blank?
    self.creation_date ||= DateTimeCommon.now
    self.metadata ||= {}
  end

  def to_h
    ATTRIBUTES.each_with_object({}) do |attr, hash|
      hash[attr.to_s] = public_send(attr)
    end
  end

  def self.from_hash(data)
    new.tap do |instance|
      ATTRIBUTES.each do |attr|
        instance.public_send("#{attr}=", data[attr.to_s])
      end
    end
  end
end