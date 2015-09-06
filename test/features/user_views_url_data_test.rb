require_relative "../test_helper"

class UserViewsUrlStatistics < FeatureTest

  def test_user_sees_statistics_for_url
    visit "/sources/jumpstartlab/urls/blog"

    within("#response_times") do
      assert page.has_content?("Longest Response Time: ")
      assert page.has_content?("Shortest Response Time: ")
      assert page.has_content?("Average Response Time: ")
    end

    within("#request_types") do
      assert page.has_content?("GET")
    end

    within ("#referrers") do
      assert page.has_content?("Most Popular Referrers: ")
    end

    within ("#user_agents") do
      assert page.has_content?("Most Popular Browser: ")
      assert page.has_content?("Most Popular Operating System: ")
    end
  end

  def test_user_sees_error_message_when_url_does_not_exist
    visit "/sources/jumpstartlab/urls/blargh"

    assert_equal "/sources/jumpstartlab/urls/blargh", current_path
    assert page.has_content?("Error Page")
    assert page.has_content?("The requested url '/blargh' does not exist")
  end

  def setup
    DatabaseCleaner.start
    source_seed_data = { identifier: "jumpstartlab",
               root_url: "http://jumpstartlab.com" }
    Source.create(source_seed_data)
    payload_hash
    payload_hash("2",2)
    payload_hash("3")
    url_seed_data = { address: "http://jumpstartlab.com/blog",
                      source_id: 1,
                      visits_count: 2,
                      average_response_time: 46 }
    url_seed_data2 = { address: "http://jumpstartlab.com/about",
                       source_id: 1,
                       visits_count: 1,
                       average_response_time: 37 }
    Url.create(url_seed_data)
    Url.create(url_seed_data2)
  end

  def teardown
    DatabaseCleaner.clean
  end

  def payload_hash(sha_id = "1", url_id = 1)
    params = {url_id: url_id,
               requested_at: "2013-02-16 21:38:28 -0700",
               responded_in: 37,
               referred_by: "http://jumpstartlab.com",
               request_type: "GET",
               parameters: [],
               event_name: "socialLogin",
               user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
               resolution_width: "1920",
               resolution_height: "1280",
               ip: "63.29.38.211",
               source_id: 1,
               sha_identifier: sha_id}
    Visit.create(params)
  end

end
