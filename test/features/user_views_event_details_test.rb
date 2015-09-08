require_relative '../test_helper'

class UserViewsEventDetailsTest < FeatureTest

  def test_user_sees_event_details
    event_seed_data = { source_id: 1,
                      name: "socialLogin" }
    event_seed_data2 = { source_id: 1,
                      name: "startedRegistration" }
    Event.create(event_seed_data)
    Event.create(event_seed_data2)
    create_visit("1", "2013-02-16 7:38:28 -0700")
    create_visit("2", "2013-02-16 7:39:28 -0700")
    create_visit("3", "2013-02-16 7:58:28 -0700")
    create_visit("4", "2013-02-16 9:38:28 -0700")
    create_visit("5", "2013-02-16 9:42:28 -0700")
    create_visit("6", "2013-02-16 12:38:28 -0700")
    create_visit("7", "2013-02-16 21:02:28 -0700")
    create_visit("7", "2013-02-16 23:12:28 -0700")

    visit "/sources/jumpstartlab/events/startedRegistration"

    within("#hour_event_received") do
      assert page.has_content?("Breakdown of Time Received")
      assert page.has_content?("00:00")
      assert page.has_content?("07:00")
      assert page.has_content?("08:00")
      assert page.has_content?("09:00")
      assert page.has_content?("12:00")
      assert page.has_content?("13:00")
      assert page.has_content?("21:00")
      assert page.has_content?("23:00")
    end

    within("#total_received") do
      assert page.has_content?("Total Times Event Received")
    end

  end

  def test_user_sees_error_message_when_event_has_not_been_defined
    event_seed_data = { source_id: 1,
                      name: "socialLogin" }

    visit "/sources/jumpstartlab/events/xlakjd"

    assert_equal "/sources/jumpstartlab/events/xlakjd", current_path
    assert page.has_content?("Error Page")
    assert page.has_content?("The event xlakjd has not been defined")
    assert find_link("jumpstartlab Events").visible?
    click_on ("jumpstartlab Events")
    assert_equal "/sources/jumpstartlab/events", current_path
  end

  def setup
    DatabaseCleaner.start
    source_seed_data = { identifier: "jumpstartlab",
               root_url: "http://jumpstartlab.com" }
    Source.create(source_seed_data)
  end

  def teardown
    DatabaseCleaner.clean
  end

  def create_visit(sha_id, time)
    params = {url_id: 1,
               requested_at: time,
               responded_in: 37,
               referred_by: "http://jumpstartlab.com",
               request_type: "GET",
               parameters: [],
               event_id: 2,
               user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
               resolution_width: "1920",
               resolution_height: "1280",
               ip: "63.29.38.211",
               source_id: 1,
               sha_identifier: sha_id}
    Visit.create(params)
  end

end
