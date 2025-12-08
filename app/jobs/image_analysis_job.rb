class ImageAnalysisJob < ApplicationJob
  queue_as :default

  def perform(wardrobe_item_id)
    wardrobe_item = WardrobeItem.find_by(id: wardrobe_item_id)
    return unless wardrobe_item
    return unless wardrobe_item.image.attached?

    # Use blob.open to get a temporary file path that works with any storage backend
    # This is compatible with local disk, S3, Azure, and other cloud storage services
    wardrobe_item.image.blob.open do |tempfile|
      image_path = tempfile.path

      Rails.logger.info "Analyzing image for WardrobeItem ##{wardrobe_item.id} at #{image_path}"

      begin
        analysis = ImageAnalysisService.new.analyze(image_path, mime_type: wardrobe_item.image.content_type)

        Rails.logger.info "Analysis result: #{analysis.inspect}"

        # Check for invalid items
        tags = analysis["tags"] || []
        description = analysis["description"]&.downcase || ""

        if tags.include?("not clothing") || tags.include?("graphic") || description.include?("not a clothing item") || analysis["category"] == "not applicable"
          Rails.logger.info "Item ##{wardrobe_item.id} identified as not clothing. Removing."

          # Broadcast removal
          Turbo::StreamsChannel.broadcast_remove_to(
            "wardrobe_stream",
            target: "wardrobe_item_#{wardrobe_item.id}"
          )

          # Broadcast error flash
          Turbo::StreamsChannel.broadcast_prepend_to(
            "wardrobe_stream",
            target: "flash_messages",
            partial: "shared/flash_message",
            locals: { message: "Item removed: Not identified as clothing.", type: "alert" }
          )

          wardrobe_item.destroy
          return
        end

        wardrobe_item.update!(
          category: analysis["category"]&.downcase,
          color: analysis["color"]&.downcase,
          metadata: {
            description: analysis["description"],
            tags: analysis["tags"]
          }
        )

        # Call Background Removal Service
        begin
          clean_path = BackgroundRemovalService.new(image_path).remove_background
          if clean_path
            wardrobe_item.cleaned_image.attach(
              io: File.open(clean_path),
              filename: "cleaned_#{wardrobe_item.id}.png",
              content_type: 'image/png'
            )
            # Clean up temp file
            File.delete(clean_path) if File.exist?(clean_path)
            Rails.logger.info "Attached cleaned image to Item ##{wardrobe_item.id}"
          end
        rescue => e
          Rails.logger.error "Background Removal failed: #{e.message}"
          # We continue even if bg removal fails
        end

        # Broadcast the update to the frontend
        # This replaces the specific card in the grid with the updated version
        Turbo::StreamsChannel.broadcast_replace_to(
          "wardrobe_stream",
          target: "wardrobe_item_#{wardrobe_item.id}",
          partial: "wardrobe_items/wardrobe_item",
          locals: { wardrobe_item: wardrobe_item }
        )

      rescue => e
        Rails.logger.error "ImageAnalysisJob failed: #{e.message}"
        # Optional: Update item with error state or retry
      end
    end
  end
end
