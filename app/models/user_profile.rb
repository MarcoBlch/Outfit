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

  # Presentation style enum
  enum presentation_style: {
    feminine: 0,
    masculine: 1,
    androgynous: 2,
    fluid: 3,
    prefer_not_to_say: 4
  }

  # Fit preference enum
  enum fit_preference: {
    relaxed: 0,
    regular: 1,
    fitted: 2,
    tailored: 3
  }

  # Wardrobe size enum
  enum wardrobe_size: {
    minimal_under_30: 0,
    small_30_to_75: 1,
    medium_75_to_150: 2,
    large_150_plus: 3
  }

  # Shopping frequency enum
  enum shopping_frequency: {
    rarely: 0,
    occasionally: 1,
    regularly: 2,
    frequently: 3
  }

  # Primary goal enum
  enum primary_goal: {
    organize_existing: 0,
    get_outfit_ideas: 1,
    reduce_wardrobe: 2,
    build_capsule: 3,
    track_value: 4,
    shop_smarter: 5
  }

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

  # Store occasion_focus as an array in the JSON column
  # Example: ["work", "casual", "formal"]
  def occasion_focus_list
    metadata&.dig("occasion_focus") || []
  end

  def occasion_focus=(occasions)
    self.metadata ||= {}
    self.metadata["occasion_focus"] = occasions.is_a?(Array) ? occasions : [occasions].compact
  end

  # Human-readable labels for occasion focus
  def occasion_focus_labels
    occasion_map = {
      "work" => "Work",
      "casual" => "Casual",
      "formal" => "Formal",
      "athletic" => "Athletic",
      "social" => "Social",
      "date_night" => "Date Night",
      "creative" => "Creative"
    }
    occasion_focus_list.map { |occasion| occasion_map[occasion] || occasion.titleize }
  end

  # Helper method to check if profile is completed
  def completed?
    style_preference.present? &&
      body_type.present? &&
      age_range.present? &&
      favorite_colors.any? &&
      location.present? &&
      presentation_style.present? &&
      occasion_focus_list.any? &&
      fit_preference.present? &&
      wardrobe_size.present? &&
      shopping_frequency.present? &&
      primary_goal.present?
  end

  # Completion percentage for progress indicators
  def completion_percentage
    fields = [
      style_preference.present?,
      body_type.present?,
      age_range.present?,
      favorite_colors.any?,
      location.present?,
      presentation_style.present?,
      occasion_focus_list.any?,
      fit_preference.present?,
      wardrobe_size.present?,
      shopping_frequency.present?,
      primary_goal.present?
    ]
    (fields.count(true).to_f / fields.size * 100).to_i
  end
end
