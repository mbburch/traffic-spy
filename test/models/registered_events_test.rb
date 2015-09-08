require_relative '../test_helper'

class RegisteredEventsTest < Minitest::Test

  def test_it_creates_a_registered_event_with_valid_attributes
    registered_event = RegisteredEvent.new(attributes)
    assert registered_event.valid?
    registered_event.save
    assert_equal 1, RegisteredEvent.count
    assert_equal 1, registered_event.id
  end

  def test_it_does_not_create_registered_event_if_missing_attributes
    attributes = {campaign_id: 1}
    registered_event = RegisteredEvent.new(attributes)

    refute registered_event.valid?
    registered_event.save
    assert_equal 0, RegisteredEvent.count
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def attributes
    {event_name: "registrationStep1",
     campaign_id: 1}
  end

end
