require_relative "../test_helper"

class UserViewsEventsIndexTest < FeatureTest

  def test_events_index_page_loads_with_correct_data
    event_seed_data = { source_id: 1,
                      name: "Social Login" }
    event_seed_data2 = { source_id: 1,
                      name: "Begin Registration" }
    Event.create(event_seed_data)
    Event.create(event_seed_data2)
    create_visit
    create_visit("2",2)
    create_visit("3")

    visit "/sources/jumpstartlab/events"

    within("#event_listing") do
      assert page.has_content?("Received Events")
      assert page.has_content?("Social Login: ")
      assert page.has_content?("Begin Registration: ")
      assert find_link("Social Login").visible?
      assert find_link("Begin Registration").visible?
    end
  end

  def test_user_sees_error_message_when_no_events_have_been_defined
    visit "/sources/jumpstartlab/events"

    assert_equal "/sources/jumpstartlab/events", current_path
    assert page.has_content?("Error Page")
    assert page.has_content?("No events have been defined")
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

  def create_visit(sha_id = "1", url_id = 1)
    params = {url_id: url_id,
               requested_at: "2013-02-16 21:38:28 -0700",
               responded_in: 37,
               referred_by: "http://jumpstartlab.com",
               request_type: "GET",
               parameters: [],
               event_id: 1,
               user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
               resolution_width: "1920",
               resolution_height: "1280",
               ip: "63.29.38.211",
               source_id: 1,
               sha_identifier: sha_id}
    Visit.create(params)
  end

end
