require_relative '../test_helper'

class UserViewsEventDetailsTest < FeatureTest

  def test_user_sees_event_details
    visit "/sources/jumpstartlabs/events/startedRegistration"

    within("#hour_event_received") do
      assert page.has_content?("Hour:")
      assert page.has_content?("#Received:")
    end

    within("#total_received") do
      assert page.has_content?("Total Received")
    end

  end

  def test_user_sees_error_message_when_event_has_not_been_defined
    visit "/sources/jumpstartlabs/events/xlakjd"

    assert_equal "/sources/jumpstartlabs/events/xlakjd", current_path
    assert page.has_content?("Error Page")
    assert page.has_content?("The event xlakjd has not been defined")
  end

end

As a user
When I submit a GET request to "sources/jumpstartlabs/events/startedRegistration"
And event has been defined
Then I should see a page that displays the following:
  Hour by hour breakdown of when the event was received. How many were shown at noon? at 1pm? at 2pm? Do it for all 24 hours.
  How many times it was recieved overall

As a user
When I submit a GET request to "sources/jumpstartlabs/events/xlakjd"
And event has not been defined
Then I should see a page that displays the following:
  Message that no event with the given name has been defined
  Hyperlink to the Application Events Index
