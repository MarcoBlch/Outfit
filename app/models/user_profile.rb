class UserProfile < ApplicationRecord
  belongs_to :user

  # Style preference enum
  enum style_preference: {
    casual: 0,
    business_casual: 1,
    formal: 2,
    streetwear: 3,
    minimalist: 4,
    bohemian: 5,
    eclectic: 6
  }

  # Body type enum (using _body_type suffix to avoid conflict with AR's .average method)
  enum :body_type, {
    slim: 0,
    athletic: 1,
    medium: 2,
    curvy: 3,
    plus_size: 4
  }, prefix: true

  # Validations
  validates :age_range, inclusion: {
    in: %w[18-24 25-34 35-44 45-54 55+],
    allow_blank: true
  }

  validates :style_preference, presence: false
  validates :body_type, presence: false

  # Store favorite_colors as an array in a JSON column
  # Example: ["blue", "black", "white"]
  def favorite_colors
    metadata&.dig("favorite_colors") || []
  end

  def favorite_colors=(colors)
    self.metadata ||= {}
    self.metadata["favorite_colors"] = colors.is_a?(Array) ? colors : [colors].compact
  end

  # Helper method to check if profile is completed
  def completed?
    style_preference.present? &&
      body_type.present? &&
      age_range.present? &&
      favorite_colors.any? &&
      location.present?
  end

  # Completion percentage for progress indicators
  def completion_percentage
    fields = [
      style_preference.present?,
      body_type.present?,
      age_range.present?,
      favorite_colors.any?,
      location.present?
    ]
    (fields.count(true).to_f / fields.size * 100).to_i
  end
end
