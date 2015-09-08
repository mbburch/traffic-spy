class Campaign < ActiveRecord::Base
  has_one :source, :through => :events
  has_many :events
  has_many :registered_events
  validates :name, presence: true, uniqueness: true
  validates :source_id, presence: true
end
