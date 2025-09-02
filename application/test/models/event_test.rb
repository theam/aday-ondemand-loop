require "test_helper"

class EventTest < ActiveSupport::TestCase

  test "initializes defaults" do
    event = Event.new(project_id: 'p1',
                      entity_type: 'project',
                      entity_id: nil,
                      message: 'message')
    assert event.id.present?
    assert event.creation_date.present?
    assert_equal({}, event.metadata)
  end

  test "to_h and from_hash preserve metadata" do
    metadata = { 'foo' => 'bar', 'count' => 1 }
    event = Event.new(project_id: 'p1',
                      entity_type: 'file',
                      entity_id: 'e1',
                      message: 'm',
                      metadata: metadata)

    hash = event.to_h
    assert_equal metadata, hash['metadata']

    reconstructed = Event.from_hash(hash)
    assert_equal metadata, reconstructed.metadata
    assert_equal event.message, reconstructed.message
    assert_equal event.entity_id, reconstructed.entity_id
  end

  test "attributes are read-only" do
    event = Event.new(project_id: 'p1', entity_type: 'project', message: 'm')
    assert_raises(NoMethodError) { event.id = 'new-id' }
    assert_raises(NoMethodError) { event.project_id = 'other' }
    assert_raises(NoMethodError) { event.metadata = {} }
  end

end

