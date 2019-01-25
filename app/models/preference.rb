class Preference < ApplicationRecord
  belongs_to :channel
  belongs_to :user
  validates_numericality_of :frequency, greater_than_or_equal_to: 0, less_than_or_equal_to: 10, message: 'must be between 0 & 10'
  validates :channel_id, uniqueness: { scope: :user_id }

end