class Recommendation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :video, :expires_at, :priority

  validate :is_video
  validates :expires_at, presence: true
  validates_numericality_of :priority, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, message: 'must be between 0 & 100'

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def is_video
    errors.add(:video, 'Video must be video class')  unless video.kind_of?(Video)
  end
end
