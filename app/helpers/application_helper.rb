module ApplicationHelper
  # Convert color names to CSS-compatible values
  COLOR_MAP = {
    "white" => "#ffffff",
    "black" => "#000000",
    "gray" => "#6b7280",
    "grey" => "#6b7280",
    "red" => "#ef4444",
    "orange" => "#f97316",
    "yellow" => "#eab308",
    "green" => "#22c55e",
    "blue" => "#3b82f6",
    "navy" => "#1e3a8a",
    "purple" => "#a855f7",
    "pink" => "#ec4899",
    "brown" => "#92400e",
    "beige" => "#d4c5a9",
    "cream" => "#fffdd0",
    "tan" => "#d2b48c",
    "khaki" => "#c3b091",
    "olive" => "#808000",
    "teal" => "#14b8a6",
    "turquoise" => "#40e0d0",
    "maroon" => "#7f1d1d",
    "burgundy" => "#800020",
    "coral" => "#ff7f50",
    "lavender" => "#e6e6fa",
    "mint" => "#98fb98",
    "gold" => "#ffd700",
    "silver" => "#c0c0c0",
    "denim" => "#1560bd",
    "charcoal" => "#36454f"
  }.freeze

  def color_to_css(color)
    return "#6b7280" if color.blank?

    normalized = color.to_s.downcase.strip
    COLOR_MAP[normalized] || normalized
  end
end
