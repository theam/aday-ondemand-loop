require "test_helper"

class EventTest < ActiveSupport::TestCase

  test "initializes defaults" do
    event = Event.new(project_id: 'p1', message: 'message', entity_type: 'project')
    assert event.id.present?
    assert event.creation_date.present?
    assert_equal({}, event.metadata)
  end

  test "to_h and from_hash preserve metadata" do
    metadata = { 'foo' => 'bar', 'count' => 1 }
    event = Event.new(project_id: 'p1', message: 'm', entity_type: 'file', entity_id: 'e1', metadata: metadata)

    hash = event.to_h
    assert_equal metadata, hash['metadata']

    reconstructed = Event.from_hash(hash)
    assert_equal metadata, reconstructed.metadata
    assert_equal event.message, reconstructed.message
    assert_equal event.entity_id, reconstructed.entity_id
  end

end

