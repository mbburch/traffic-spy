class Event < ActiveRecord::Base
  has_many :visits, dependent: :destroy
  has_one :source, :through => :visits
  validates :name, presence: true
  validates :source_id, presence: true
end
