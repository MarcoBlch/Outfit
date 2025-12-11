module AdminHelper
  # Tier badge colors
  def tier_badge_color(tier)
    case tier&.downcase
    when 'pro'
      'bg-pink-500/20 text-pink-400 border border-pink-500/30'
    when 'premium'
      'bg-purple-500/20 text-purple-400 border border-purple-500/30'
    else
      'bg-gray-500/20 text-gray-400 border border-gray-500/30'
    end
  end

  # Retention rate color coding
  def retention_color(rate)
    return 'bg-gray-500/20 text-gray-400' if rate.nil? || rate == 0

    if rate >= 70
      'bg-green-500/20 text-green-400'
    elsif rate >= 50
      'bg-yellow-500/20 text-yellow-400'
    elsif rate >= 30
      'bg-orange-500/20 text-orange-400'
    else
      'bg-red-500/20 text-red-400'
    end
  end

  # Usage intensity color for heatmap
  def usage_intensity_color(intensity)
    return 'bg-white/5' if intensity == 0

    if intensity >= 75
      'bg-primary'
    elsif intensity >= 50
      'bg-primary/70'
    elsif intensity >= 25
      'bg-primary/40'
    else
      'bg-primary/20'
    end
  end

  # Format large numbers with K/M suffix
  def format_number(number)
    return '0' if number.nil? || number == 0

    if number >= 1_000_000
      "#{(number / 1_000_000.0).round(1)}M"
    elsif number >= 1_000
      "#{(number / 1_000.0).round(1)}K"
    else
      number.to_s
    end
  end

  # Activity icon helper
  def activity_icon(type, size: 'w-4 h-4')
    icons = {
      user_joined: %(<svg class="#{size} text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>
      </svg>).html_safe,

      subscription_created: %(<svg class="#{size} text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"></path>
      </svg>).html_safe,

      subscription_cancelled: %(<svg class="#{size} text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
      </svg>).html_safe,

      outfit_created: %(<svg class="#{size} text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
      </svg>).html_safe,

      wardrobe_item_added: %(<svg class="#{size} text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
      </svg>).html_safe,

      ai_suggestion_used: %(<svg class="#{size} text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
      </svg>).html_safe
    }

    icons[type.to_sym] || icons[:user_joined]
  end

  # Activity color helper
  def activity_color(type)
    colors = {
      user_joined: 'bg-gradient-to-br from-blue-500 to-blue-600',
      subscription_created: 'bg-gradient-to-br from-green-500 to-green-600',
      subscription_cancelled: 'bg-gradient-to-br from-red-500 to-red-600',
      outfit_created: 'bg-gradient-to-br from-purple-500 to-purple-600',
      wardrobe_item_added: 'bg-gradient-to-br from-indigo-500 to-indigo-600',
      ai_suggestion_used: 'bg-gradient-to-br from-yellow-500 to-yellow-600'
    }

    colors[type.to_sym] || 'bg-gradient-to-br from-gray-500 to-gray-600'
  end

  # Event badge colors
  def event_badge_color(event_type)
    case event_type&.downcase
    when 'upgrade', 'created'
      'bg-green-500/20 text-green-400 border border-green-500/30'
    when 'downgrade'
      'bg-orange-500/20 text-orange-400 border border-orange-500/30'
    when 'cancelled', 'cancel'
      'bg-red-500/20 text-red-400 border border-red-500/30'
    else
      'bg-blue-500/20 text-blue-400 border border-blue-500/30'
    end
  end
end
