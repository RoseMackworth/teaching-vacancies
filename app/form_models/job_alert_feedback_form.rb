class JobAlertFeedbackForm
  include ActiveModel::Model

  attr_accessor :comment

  validates :comment, presence: true
  validates :comment, length: { maximum: 1200 }
end
