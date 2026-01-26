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

  # Weather display helpers
  def weather_gradient_class(condition)
    return "from-gray-400 to-gray-500" if condition.blank?

    case condition.to_s.downcase
    when "clear", "sunny"
      "from-yellow-400 to-orange-500"
    when "clouds", "cloudy", "overcast", "partly cloudy"
      "from-gray-400 to-slate-500"
    when "rain", "drizzle", "shower"
      "from-blue-400 to-slate-600"
    when "thunderstorm", "storm"
      "from-purple-600 to-slate-800"
    when "snow", "sleet", "hail"
      "from-blue-200 to-slate-400"
    when "mist", "fog", "haze"
      "from-gray-300 to-gray-500"
    else
      "from-blue-400 to-cyan-500"
    end
  end

  def weather_icon(condition)
    icon_svg = case condition.to_s.downcase
    when "clear", "sunny"
      # Sun icon
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"></path>'
    when "clouds", "cloudy", "overcast", "partly cloudy"
      # Cloud icon
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z"></path>'
    when "rain", "drizzle", "shower"
      # Rain icon (cloud with lines)
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 19v2m4-2v2m4-2v2"></path>'
    when "thunderstorm", "storm"
      # Lightning icon
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>'
    when "snow", "sleet", "hail"
      # Snowflake-like pattern (asterisk)
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v18m9-9H3m12.364-6.364l-8.728 8.728m0-8.728l8.728 8.728"></path>'
    else
      # Default cloud icon
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z"></path>'
    end

    raw('<svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">' + icon_svg + '</svg>')
  end
end
