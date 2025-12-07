class WardrobeSearchService
  class SearchError < StandardError; end

  def initialize(user)
    @user = user
    @embedding_service = EmbeddingService.new
  end

  # Search wardrobe by uploading an image
  # Returns similar items from the user's wardrobe
  def search_by_image(image_file, limit: 10)
    validate_premium_access!

    # Generate embedding for the uploaded image
    start_time = Time.current
    image_embedding = generate_image_embedding(image_file)
    embedding_time = ((Time.current - start_time) * 1000).to_i

    # Find similar items using pgvector
    similar_items = find_similar_items(image_embedding, limit)

    # Record the search usage
    @user.record_image_search!

    {
      items: similar_items,
      metadata: {
        embedding_time_ms: embedding_time,
        results_count: similar_items.size,
        remaining_searches: @user.remaining_image_searches_today
      }
    }
  rescue EmbeddingService::EmbeddingError => e
    Rails.logger.error("Image search embedding failed: #{e.message}")
    raise SearchError, "Failed to process image: #{e.message}"
  end

  # Search wardrobe by text description
  def search_by_text(query, limit: 10)
    return { items: [], metadata: { results_count: 0 } } if query.blank?

    # Generate text embedding
    text_embedding = @embedding_service.embed(query)

    # Find similar items
    similar_items = find_similar_items(text_embedding, limit)

    {
      items: similar_items,
      metadata: {
        query: query,
        results_count: similar_items.size
      }
    }
  rescue EmbeddingService::EmbeddingError => e
    Rails.logger.error("Text search embedding failed: #{e.message}")
    raise SearchError, "Failed to process search query: #{e.message}"
  end

  private

  def validate_premium_access!
    unless @user.can_search_images?
      if @user.free_tier?
        raise SearchError, "Image search is a Premium feature. Please upgrade to search by image."
      else
        raise SearchError, "You've reached your daily image search limit. Try again tomorrow."
      end
    end
  end

  def generate_image_embedding(image_file)
    # Handle ActiveStorage attachment or direct file upload
    if image_file.respond_to?(:download)
      # ActiveStorage blob
      image_data = image_file.download
      @embedding_service.embed_image(Base64.strict_encode64(image_data))
    elsif image_file.respond_to?(:read)
      # ActionDispatch::Http::UploadedFile or similar
      image_data = image_file.read
      image_file.rewind if image_file.respond_to?(:rewind)
      @embedding_service.embed_image(Base64.strict_encode64(image_data))
    elsif image_file.is_a?(String) && File.exist?(image_file)
      # File path
      @embedding_service.embed_image(image_file)
    else
      raise SearchError, "Invalid image format provided"
    end
  end

  def find_similar_items(embedding, limit)
    return [] if embedding.blank?

    # Use pgvector's nearest neighbor search
    # Lower distance = more similar
    embedding_string = "[#{embedding.join(',')}]"

    @user.wardrobe_items
      .where.not(embedding: nil)
      .select("wardrobe_items.*, embedding <-> '#{embedding_string}' AS distance")
      .order(Arel.sql("embedding <-> '#{embedding_string}'"))
      .limit(limit)
      .map do |item|
        {
          item: item,
          similarity_score: calculate_similarity(item.attributes["distance"])
        }
      end
  end

  # Convert distance to similarity score (0-100)
  # pgvector uses L2 distance by default, smaller = more similar
  def calculate_similarity(distance)
    return 100 if distance.nil? || distance <= 0
    # Normalize to 0-100 scale
    # Typical L2 distances for 768-dim embeddings range from 0 to ~50
    similarity = [100 - (distance * 5), 0].max
    similarity.round(1)
  end
end
