# Maintenance Guide

## Vertex AI Models

This application relies on Google Cloud Vertex AI for image analysis and text generation.

### Current Models (as of December 2025)

| Feature | Service/Script | Model Alias | Notes |
| :--- | :--- | :--- | :--- |
| **Image Analysis** | `ImageAnalysisService` | `gemini-2.5-flash` | Multimodal, optimized for speed and cost. |
| **Text Generation** | `verify_text_api.rb` | `gemini-2.5-flash` | General purpose text generation. |
| **Embeddings** | `SearchService` (implied) | `text-embedding-004` | For vector search. |

### Model Lifecycle & Deprecation

Google periodically retires older model versions. **It is critical to check for deprecation notices quarterly.**

- **Official Lifecycle Page**: [Vertex AI Model Versions](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versions)
- **Auto-Updated Aliases**: We use aliases (e.g., `gemini-2.5-flash`) instead of specific versions (e.g., `gemini-2.5-flash-001`) to automatically receive stable updates. However, major version upgrades (e.g., 2.5 to 3.0) will require code changes.

### How to Update Models

1.  **Check Availability**: Ensure the new model is available in your Google Cloud region (`us-central1`).
2.  **Update Code**:
    *   `app/services/image_analysis_service.rb`: Update `@api_endpoint`.
    *   `scripts/verify/verify_text_api.rb`: Update `model_id`.
3.  **Verify**: Run the verification scripts in `scripts/verify/`.

```bash
ruby scripts/verify/verify_vision_api.rb
ruby scripts/verify/verify_text_api.rb
```
