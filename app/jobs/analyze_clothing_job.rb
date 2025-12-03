class AnalyzeClothingJob < ApplicationJob
  queue_as :default

  def perform(wardrobe_item_id)
    item = WardrobeItem.find_by(id: wardrobe_item_id)
    return unless item
    return unless item.image.attached?

    # Download image to temp file for analysis
    item.image.open do |tempfile|
      service = ImageAnalysisService.new
      analysis_result = service.analyze(tempfile.path)

      # Update item with analysis results
      # Update item with analysis results
      item.update!(
        category: analysis_result["category"] || item.category,
        color: analysis_result["color"],
        metadata: (item.metadata || {}).merge(analysis_result)
      )
      
      # Generate and save embedding for the description
      description = analysis_result["description"]
      if description.present?
        embedding = EmbeddingService.new.embed(description)
        item.update!(embedding: embedding)
      end
    end
  rescue => e
    Rails.logger.error("Failed to analyze wardrobe item #{wardrobe_item_id}: #{e.message}")
    # Optionally retry or handle error state
  end
end
