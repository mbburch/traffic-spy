class RegisteredEvent < ActiveRecord::Base
  has_one :campaign, :through => :campaigns
  has_many :events
  has_many :registered_events
  validates :event_name, presence: true
  validates :campaign_id, presence: true
end
