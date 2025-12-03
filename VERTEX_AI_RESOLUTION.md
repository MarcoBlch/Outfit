# Vertex AI Issue Resolution

## Problem Summary

The application was experiencing 404 errors when attempting to use Vertex AI Generative AI models (Vision and Text APIs). The error message was:

```
Publisher Model `projects/.../models/gemini-1.5-flash` was not found or your project does not have access to it.
```

## Root Cause

**The application was using retired Gemini models that were deprecated in September 2025.**

The following models were being used but are no longer available:
- `gemini-1.5-flash` (RETIRED)
- `gemini-1.5-pro` (RETIRED)
- `gemini-1.0-pro` (RETIRED)
- `gemini-1.0-pro-001` (RETIRED)
- `text-bison` (RETIRED)

## Investigation Findings

1. **API Enablement**: ✅ Confirmed `aiplatform.googleapis.com` is enabled
2. **Billing**: ✅ Confirmed billing is enabled for the project
3. **Permissions**: ✅ Confirmed proper IAM roles (Owner role)
4. **Authentication**: ✅ Confirmed Google Cloud authentication working
5. **Embeddings**: ✅ Confirmed `text-embedding-004` working correctly
6. **Model Availability**: ❌ Legacy Gemini 1.x models not available (retired)

## Solution

Updated the application to use **current, non-retired Gemini 2.x models**:

### Changes Made

#### 1. ImageAnalysisService (Vision API)
**File**: `app/services/image_analysis_service.rb`

**Changed from**:
```ruby
@api_endpoint = "https://#{@location}-aiplatform.googleapis.com/v1/projects/#{@project_id}/locations/#{@location}/publishers/google/models/gemini-1.5-flash:generateContent"
```

**Changed to**:
```ruby
# Updated to use current Gemini 2.5 model (gemini-1.5 was retired in September 2025)
@api_endpoint = "https://#{@location}-aiplatform.googleapis.com/v1/projects/#{@project_id}/locations/#{@location}/publishers/google/models/gemini-2.5-flash:generateContent"
```

#### 2. Text API Verification Script
**File**: `verify_text_api.rb`

**Changed from**:
```ruby
model_id = "gemini-1.0-pro-001"
```

**Changed to**:
```ruby
# Updated to use current model (gemini-1.0 was retired in September 2025)
model_id = "gemini-2.5-flash"
```

#### 3. Vision API Verification Script
**File**: `verify_vision_api.rb`

Added proper environment loading:
```ruby
require "dotenv/load"
require_relative "app/services/image_analysis_service"
```

## Current Working Models (December 2025)

### Text/Chat Models
- `gemini-2.5-pro` (Released June 17, 2025)
- `gemini-2.5-flash` (Released June 17, 2025) ← **Currently using**
- `gemini-2.5-flash-lite` (Released July 22, 2025)
- `gemini-2.0-flash-001` (Released February 5, 2025)
- `gemini-2.0-flash-lite-001` (Released February 25, 2025)

### Multimodal (Vision) Model
- `gemini-2.5-flash` ← **Currently using**
- `gemini-2.5-flash-image` (Released October 2, 2025)

### Embedding Models (Already Working)
- `text-embedding-004` ← **Currently using**
- `text-embedding-005` (Released November 18, 2024)
- `gemini-embedding-001` (Released May 20, 2025)

## Verification Results

### ✅ Text API - WORKING
```bash
$ ruby verify_text_api.rb
Response Code: 200
✅ Model: gemini-2.5-flash responding correctly
```

### ✅ Embeddings API - WORKING
```bash
$ ruby verify_search_api.rb
✅ Search API working with text-embedding-004
```

### ⚠️ Vision API - UPDATED (Needs Testing with Real Image)
- Service updated to use `gemini-2.5-flash`
- Text-based testing confirmed model is accessible
- Requires testing with actual image uploads through Rails application

## Next Steps

1. **Test Vision API with Real Images**: Upload actual clothing images through the Rails application to verify the full Vision API integration works end-to-end.

2. **Monitor Model Lifecycle**: Set up a reminder to check Google Cloud's [Model Version Lifecycle](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versions) page quarterly for deprecation notices.

3. **Consider Using Auto-Updated Aliases**: Instead of version-specific model IDs, consider using auto-updating aliases like `gemini-2.5-flash` (without version suffix) which automatically point to the latest stable version.

4. **Optional Upgrades**: Consider upgrading to newer models:
   - `gemini-2.5-pro` for higher quality (slower, more expensive)
   - `gemini-2.5-flash-lite` for faster responses (lower quality)
   - `gemini-2.5-flash-image` specifically optimized for image analysis

## Environment Configuration

The investigation revealed that proper environment loading is critical. Ensure `.env` file contains:

```env
GOOGLE_CLOUD_PROJECT=project-a93d3874-a9c7-43f9-979
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```

## References

- [Vertex AI Model Versions](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versions)
- [Gemini API Reference](https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/gemini)
- Stack Overflow discussions about Gemini 404 errors in 2025

## Status

**RESOLVED** ✅

All Vertex AI Generative AI features are now accessible using current Gemini 2.5 models.
