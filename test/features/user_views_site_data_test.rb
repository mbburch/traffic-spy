require_relative "../test_helper"

class UserViewsSiteDataTest < FeatureTest

  def setup
    DatabaseCleaner.start
    seed_data = { identifier: "jumpstartlab",
               root_url: "http://jumpstartlab.com" }
    Source.create(seed_data)
    payload_hash
    payload_hash("2","http://jumpstartlab.com/about")
    payload_hash("3")
  end

  def payload_hash(sha_id = "1", url = "http://jumpstartlab.com/blog")
    params = {url: url,
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

  def teardown
    DatabaseCleaner.clean
  end

  def test_user_sees_aggregate_data
    visit "/sources/jumpstartlab"

    assert_equal "/sources/jumpstartlab", current_path

    within(".page-header") do
      assert page.has_content?("Jumpstartlab Site Data")
    end

    within("#urls") do
      assert page.has_content?("Requested URLs")
      assert page.has_content?("http://jumpstartlab.com/blog: 2 visits")
      assert page.has_content?("http://jumpstartlab.com/about: 1 visits")
    end

    within("#browsers") do
      assert page.has_content?("Web Browser Breakdown")
      assert page.has_content?("Chrome: 3")
    end

    within("#os") do
      assert page.has_content?("OS Breakdown")
      assert page.has_content?("Macintosh: 3")
    end

    within("#screen_resolutions") do
      assert page.has_content?("Screen Resolutions")
      assert page.has_content?("1920x1280")
    end

    # within("#response_times") do
    #   skip
    #   assert page.has_content?("")
    # end

  end


end

# As a user
# XWhen I submit a GET request to "/sources/jumpstartlab"
# XThen I should see a page that displays the following:
#   XMost requested URLS to least requested URLS (url)
#   XWeb browser breakdown across all requests (userAgent)
#   XOS breakdown across all requests (userAgent)
#   XScreen Resolution across all requests (resolutionWidth x resolutionHeight)
#   Longest, average response time per URL to shortest, average response time per URL
#   Hyperlinks of each url to view url specific data
#   Hyperlink to view aggregate event data
#
# As a user
#   When I submit a GET request to "/sources/jumpstartsslab"
#   And the identifier does not exist
#   Then I should see a page that displays the following message:
#     "That identifier does not exist."