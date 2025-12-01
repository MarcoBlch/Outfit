FactoryBot.define do
  factory :outfit_item do
    outfit { nil }
    wardrobe_item { nil }
    position_x { 1.5 }
    position_y { 1.5 }
    scale { 1.5 }
    rotation { 1.5 }
    z_index { 1 }
  end
end
