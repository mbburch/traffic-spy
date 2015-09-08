require_relative '../test_helper'

class EventTest < Minitest::Test

  def test_it_creates_a_event_with_valid_attributes
    event = Event.new(attributes)
    assert event.valid?
    event.save
    assert_equal 1, Event.count
  end

  def test_it_does_not_create_event_if_missing_attributes
    attributes = {source_id: 1}
    event = Event.new(attributes)

    refute event.valid?
    event.save
    assert_equal 0, Event.count
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def attributes
    {name: "Social Login",
     source_id: 1}
  end

end
