class EmergencyLoginKey < ApplicationRecord
  belongs_to :publisher
  validates :not_valid_after, presence: true

  def expired?
    Time.current > not_valid_after
  end
end
