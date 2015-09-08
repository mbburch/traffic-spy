class CreateCampaignTables

  def self.create(params, source_id)
    campaign = create_campaign(params[:campaignName], source_id)
    create_registered_event(params[:eventNames], campaign.id)
  end

  private

  def self.create_campaign(campaign, source_id)
    campaign = Campaign.new(name: campaign, source_id: source_id)
    campaign.save
    campaign
  end

  def self.create_registered_event(param, campaign_id)
    event_names = param.first.split('eventNames[]=')
    event_names.each do |event|
      reg_ev = RegisteredEvent.new(event_name: event, campaign_id: campaign_id)
      reg_ev.save
    end
  end
end
