require_relative '../test_helper'

class CampaignTest < Minitest::Test

  def test_it_creates_a_campaign_with_valid_attributes
    campaign = Campaign.new(attributes)
    assert campaign.valid?
    campaign.save
    assert_equal 1, Campaign.count
    assert_equal 1, campaign.id
  end

  def test_it_does_not_create_campaign_if_missing_attributes
    attributes = {source_id: 1}
    campaign = Campaign.new(attributes)

    refute campaign.valid?
    campaign.save
    assert_equal 0, Campaign.count
  end

  def test_it_does_not_create_url_with_non_unique_attribute
    campaign = Campaign.new(attributes)
    campaign2 = Campaign.new(attributes)

    assert campaign.valid?
    campaign.save
    refute campaign2.valid?
    campaign2.save
    assert_equal 1, Campaign.count
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def attributes
    {name: "socialSignup",
     source_id: 1}
  end

end
