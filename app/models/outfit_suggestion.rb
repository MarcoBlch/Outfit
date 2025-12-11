class OutfitSuggestion < ApplicationRecord
  belongs_to :user

  validates :context, presence: true
  validates :status, inclusion: { in: %w[pending completed failed] }

  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: 'completed') }
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', 1.week.ago) }
  scope :this_month, -> { where('created_at >= ?', 1.month.ago) }
  scope :failed, -> { where(status: 'failed') }

  # Store validated outfit combinations
  # Structure: [
  #   {
  #     rank: 1,
  #     confidence: 0.95,
  #     reasoning: "Professional yet approachable...",
  #     items: [
  #       { id: 123, category: "shirt", role: "top" },
  #       { id: 456, category: "pants", role: "bottom" }
  #     ]
  #   }
  # ]

  def mark_completed!(validated_data, response_time_ms, api_cost = 0.01)
    update!(
      status: 'completed',
      validated_suggestions: validated_data,
      suggestions_count: validated_data.size,
      response_time_ms: response_time_ms,
      api_cost: api_cost
    )
  end

  def mark_failed!(error_msg)
    update!(
      status: 'failed',
      error_message: error_msg
    )
  end
end
