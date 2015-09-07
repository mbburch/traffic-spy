require_relative "../test_helper"

class UserViewsUrlStatistics < FeatureTest

  def test_user_sees_statistics_for_url
    visit "/sources/jumpstartlab/urls/blog"

    within("#response_times") do
      assert page.has_content?("Maximum Response Time: 77")
      assert page.has_content?("Minimum Response Time: 29")
      assert page.has_content?("Average Response Time: 46")
    end

    within("#request_types") do
      assert page.has_content?("GET")
    end

    within ("#referrers") do
      assert page.has_content?("Most Popular Referrers")
    end

    within ("#user_agents") do
      assert page.has_content?("Most Popular Browsers")
      assert page.has_content?("Chrome")
      assert page.has_content?("Most Popular Operating Systems")
      assert page.has_content?("Macintosh")
    end
  end

  def test_user_sees_error_message_when_url_does_not_exist
    visit "/sources/jumpstartlab/urls/blargh"

    assert_equal "/sources/jumpstartlab/urls/blargh", current_path
    assert page.has_content?("Error Page")
    assert page.has_content?("The requested url '/blargh' has not been requested")
  end

  def setup
    DatabaseCleaner.start
    source_seed_data = { identifier: "jumpstartlab",
               root_url: "http://jumpstartlab.com" }
    Source.create(source_seed_data)
    create_visit
    create_visit("2",29)
    create_visit("3", 43)
    create_visit("4", 77)
    url_seed_data = { address: "http://jumpstartlab.com/blog",
                      source_id: 1}
    Url.create(url_seed_data)
  end

  def teardown
    DatabaseCleaner.clean
  end

  def create_visit(sha_id = "1", responded_in = 37)
    params = {url_id: 1,
               requested_at: "2013-02-16 21:38:28 -0700",
               responded_in: responded_in,
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
