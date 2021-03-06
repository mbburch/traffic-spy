require_relative "../test_helper"

class ServerTest < Minitest::Test
  include Rack::Test::Methods

  def test_it_creates_a_source_with_valid_attributes
    params = { identifier: "jumpstartlab",
               rootUrl: "http://jumpstartlab.com" }
    post "/sources", params

    assert_equal 1, Source.count
    assert_equal 200, last_response.status
    assert_equal "{\"identifier\":\"jumpstartlab\"}", last_response.body
  end

  def test_it_doesnt_create_source_with_missing_attributes
    params = { rootUrl: "http://jumpstartlab.com" }
    post "/sources", params

    assert_equal 0, Source.count
    assert_equal 400, last_response.status
    assert_equal "Missing Parameters: Identifier can't be blank", last_response.body
  end

  def test_it_does_not_create_source_with_non_unique_attributes
    params = { identifier: "jumpstartlab",
               rootUrl: "http://jumpstartlab.com" }
    create_source
    post "/sources", params

    assert_equal 1, Source.count
    assert_equal 403, last_response.status
    assert_equal "Non-unique Value: Identifier has already been taken", last_response.body
  end

  def test_it_creates_visit_with_valid_attributes
    create_source
    payload = payload_hash
    post "/sources/jumpstartlab/data", payload

    visit = Visit.find_by(referred_by: "http://jumpstartlab.com")

    assert_equal 1, Url.count
    assert_equal 1, visit.url_id
    assert_equal 200, last_response.status
    assert_equal 1, visit.source_id
  end

  def test_it_does_not_create_a_visit_when_payload_has_already_been_recieved
    create_source
    params = payload_hash
    post "/sources/jumpstartlab/data", params
    post "/sources/jumpstartlab/data", params

    assert_equal 403, last_response.status
    assert_equal "Payload Has Already Been Received", last_response.body
  end

  def test_it_does_not_create_visit_when_missing_payload
    create_source
    params = {}
    post "/sources/jumpstartlab/data", params

    assert_equal 400, last_response.status
    assert_equal "Missing Payload", last_response.body
  end

  def test_it_does_not_create_visit_when_payload_empty
    create_source
    params = {payload: ""}
    post "/sources/jumpstartlab/data", params
    assert_equal 400, last_response.status
    assert_equal "Missing Payload", last_response.body
  end

  def test_it_does_not_create_visit_with_an_invalid_identifier
    create_source
    params = payload_hash
    post "/sources/jumpstartlabsss/data", params

    assert_equal 403, last_response.status
    assert_equal "Application Not Registered", last_response.body
  end

  def test_it_does_not_create_a_campaign_when_campaign_has_been_received
    create_source
    create_campaign
    params = campaign_params
    post "/sources/jumpstartlab/campaigns", params
    post "/sources/jumpstartlab/campaigns", params

    assert_equal 403, last_response.status
    assert_equal "Campaign Already Registered", last_response.body
  end

  def test_it_does_not_create_campaigns_when_missing_both_parameters
    create_source
    params = {}
    post "/sources/jumpstartlab/campaigns", params

    assert_equal 400, last_response.status
    assert_equal "Missing Parameters", last_response.body
  end

  def test_it_does_not_create_campaigns_when_missing_event_names_params
    create_source
    params = 'campaignName=socialSignup'
    post "/sources/jumpstartlab/campaigns", params

    assert_equal 400, last_response.status
    assert_equal "Missing Parameters", last_response.body
  end

  def test_it_does_not_create_campaigns_when_missing_campaign_params
    create_source
    params = 'eventNames[]=registrationStep1'
    post "/sources/jumpstartlab/campaigns", params

    assert_equal 400, last_response.status
    assert_equal "Missing Parameters", last_response.body
  end

  def test_it_does_not_create_campaign_with_an_invalid_identifier
    create_source
    params = campaign_params
    post "/sources/jumpstartlabsss/campaigns", params

    assert_equal 403, last_response.status
    assert_equal "Application Not Registered", last_response.body
  end

  def test_it_creates_a_campaign_and_registered_event
    create_source
    params = campaign_params
    post "/sources/jumpstartlab/campaigns", params

    assert_equal 1, Campaign.count
    assert_equal 2, RegisteredEvent.count
    assert_equal 1, Campaign.first.id
    assert_equal 1, Campaign.first.source_id
    assert_equal 'socialSignup', Campaign.first.name
    assert_equal 1, RegisteredEvent.first.id
    assert_equal 1, RegisteredEvent.first.campaign_id
    assert_equal 'registrationStep1', RegisteredEvent.first.event_name
    assert_equal 2, RegisteredEvent.last.id
    assert_equal 1, RegisteredEvent.last.campaign_id
    assert_equal 'registrationStep2', RegisteredEvent.last.event_name
  end


  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def app
    TrafficSpy::Server
  end

  def create_source
    seed_data = { identifier: "jumpstartlab",
               root_url: "http://jumpstartlab.com" }
    Source.create(seed_data)
  end

  def create_campaign
    seed_data = {name: "socialSignup",
     source_id: 1 }
     Campaign.create(seed_data)
  end

  def create_registered_event
    seed_data = {event_name: "registrationStep1",
     campaign_id: 1}
     RegisteredEvent.new(seed_data)
  end

  def campaign_params
    'campaignName=socialSignup&eventNames[]=registrationStep1eventNames[]=registrationStep2'
  end

  def payload_hash
    {payload: {url: "http://jumpstartlab.com/blog",
               requestedAt: "2013-02-16 21:38:28 -0700",
               respondedIn: 37,
               referredBy: "http://jumpstartlab.com",
               requestType: "GET",
               parameters: "[]",
               eventName: "socialLogin",
               userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
               resolutionWidth: "1920",
               resolutionHeight: "1280",
               ip: "63.29.38.211"}.to_json}
  end

end
