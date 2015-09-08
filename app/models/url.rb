class Url < ActiveRecord::Base
  has_one :source, :through => :visits
  has_many :visits
  validates :address, presence: true, uniqueness: true
  validates :source_id, presence: true
end
