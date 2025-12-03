# Verification Scripts

This folder contains scripts to verify that various APIs and services are working correctly.

## Prerequisites

All scripts require:
- `.env` file with Google Cloud credentials configured
- `dotenv` gem installed: `gem install dotenv`
- Active Google Cloud Project with appropriate APIs enabled

## Available Scripts

### Core API Verification

**verify_wardrobe.rb**
- Tests wardrobe item creation
- Verifies embedding generation and storage
- Confirms database integration

**verify_outfits_api.rb**
- Tests outfit CRUD operations
- Verifies outfit-wardrobe item associations
- Checks API endpoints

### Vertex AI Verification

**verify_search_api.rb**
- Tests vector similarity search
- Verifies pgvector integration
- Confirms text-embedding-004 model

**verify_text_api.rb**
- Tests Gemini text generation
- Verifies gemini-2.5-flash model
- Confirms API authentication

**verify_vision_api.rb**
- Tests image analysis with Gemini
- Verifies multimodal API
- Requires test image in `tmp/test_image.jpg`

## Usage

Run any script from the project root:

```bash
ruby scripts/verify/verify_wardrobe.rb
ruby scripts/verify/verify_search_api.rb
ruby scripts/verify/verify_text_api.rb
```

## Expected Output

All scripts should output their status and either:
- ✅ SUCCESS messages when working correctly
- ❌ ERROR messages with details when failing

## Troubleshooting

If scripts fail:

1. Check `.env` file has correct credentials
2. Verify Google Cloud APIs are enabled
3. Confirm billing is active
4. Check model versions are current (see `VERTEX_AI_RESOLUTION.md`)
