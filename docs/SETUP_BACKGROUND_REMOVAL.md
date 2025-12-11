# Background Removal Setup

This document explains how to set up and use the background removal feature for wardrobe items.

## Overview

The Outfit application uses the `rembg` Python library to automatically remove backgrounds from wardrobe item images. This creates cleaner images that work better for outfit visualization and matching.

## Requirements

- Python 3.7+ with pip
- rembg Python package with CLI support
- onnxruntime (dependency for rembg)

## Installation

### Option 1: System-wide Installation (Recommended)

Install rembg globally using pip with the `--break-system-packages` flag (safe in WSL/development environments):

```bash
pip install --break-system-packages "rembg[cli]"
pip install --break-system-packages onnxruntime
```

### Option 2: Virtual Environment Installation

If you prefer using a virtual environment:

```bash
# Create venv if not exists
python3 -m venv .venv

# Activate venv
source .venv/bin/activate

# Install rembg with CLI support
pip install "rembg[cli]"
pip install onnxruntime

# Deactivate when done
deactivate
```

The BackgroundRemovalService will automatically detect and use the correct rembg installation.

## Verify Installation

Check that rembg is installed and working:

```bash
# Check command location
which rembg

# Test help command
rembg --help
```

You should see output showing rembg's available commands.

## Test Background Removal

Run the test script to verify background removal works with your database:

```bash
rails runner tmp/test_rembg.rb
```

Expected output:
```
Testing rembg installation...
✓ Found wardrobe item #38
✓ Image saved to: /home/marc/code/MarcoBlch/Outfit/tmp/test_input.jpg
✓ Image size: 495468 bytes

Testing BackgroundRemovalService...
✅ Background removal successful!
   File size: 596083 bytes
   Saved to: /home/marc/code/MarcoBlch/Outfit/tmp/test_input_nobg.png
```

## How It Works

### Automatic Processing

When a user uploads an image to their wardrobe:

1. The image is saved to ActiveStorage
2. `ImageAnalysisJob` is triggered automatically (via callback or manually)
3. `BackgroundRemovalService` processes the image using `rembg`
4. The cleaned image (with background removed) is attached as `cleaned_image`
5. Views automatically display the cleaned version if available

### Service Architecture

**BackgroundRemovalService** (`app/services/background_removal_service.rb`):
- Takes an image path as input
- Calls `rembg i input.png output.png` via shell command
- Returns the path to the processed image
- Handles errors gracefully (logs but doesn't crash)
- Automatically detects rembg location (system or venv)

**ImageAnalysisJob** (`app/jobs/image_analysis_job.rb`):
- Runs asynchronously to process wardrobe item images
- Downloads the original image to a temp file
- Calls BackgroundRemovalService
- Attaches the cleaned image to the wardrobe item

### Model Changes

**WardrobeItem** model has two image attachments:
- `image`: Original uploaded image
- `cleaned_image`: Background-removed version (optional)

## Process Existing Images

To add background removal to existing wardrobe items that don't have cleaned images yet:

```bash
rails runner tmp/process_existing_items.rb
```

This script will:
- Find all items with original images but no cleaned images
- Process each one through ImageAnalysisJob
- Report success/failure statistics

**Warning**: This can take time if you have many images. Consider running in batches for large datasets.

## Troubleshooting

### Error: "rembg: command not found"

**Cause**: rembg is not installed or not in PATH

**Solution**:
```bash
pip install --break-system-packages "rembg[cli]"
pip install --break-system-packages onnxruntime
```

### Error: "No module named 'onnxruntime'"

**Cause**: onnxruntime dependency is missing

**Solution**:
```bash
pip install --break-system-packages onnxruntime
```

Or if using venv:
```bash
.venv/bin/pip install onnxruntime
```

### Background removal fails silently

**Symptoms**: No cleaned_image is created, but no error is shown

**Debugging**:

1. Check Rails logs for error messages:
```bash
tail -f log/development.log
```

2. Run the test script to see detailed output:
```bash
rails runner tmp/test_rembg.rb
```

3. Check if rembg works directly:
```bash
rembg i input.jpg output.png
```

### Common Issues

1. **Empty image files**: Some wardrobe items may have 0-byte images (corrupted uploads). The script will skip these automatically.

2. **Model download**: On first run, rembg will download an AI model (u2net) which can take a few minutes. Subsequent runs will be faster.

3. **Memory usage**: Background removal is memory-intensive. If you have limited RAM, process items in small batches.

## Configuration

### Storage Location

Background removal works with any ActiveStorage backend:
- Local disk (development)
- S3-compatible storage (production)
- Other ActiveStorage adapters

The service uses temporary files for processing and automatically uploads the result to your configured storage.

### Performance Tuning

For production environments:

1. **Use background jobs**: Ensure ImageAnalysisJob runs via Sidekiq or similar (not inline)

2. **Rate limiting**: Add delays between batch processing to avoid overwhelming the server

3. **Timeout configuration**: Large images may need longer processing times

## Development vs Production

### Development
- rembg can be installed system-wide (simpler)
- Processing happens synchronously for easier debugging
- Temporary files stored in `tmp/`

### Production
- Consider using a dedicated Python service/container for rembg
- Process via background jobs (Sidekiq)
- Monitor memory usage and job timeouts
- Consider caching or pre-processing images during off-peak hours

## Additional Resources

- [rembg Documentation](https://github.com/danielgatis/rembg)
- [ActiveStorage Guide](https://guides.rubyonrails.org/active_storage_overview.html)
- [BackgroundRemovalService](../app/services/background_removal_service.rb)
- [ImageAnalysisJob](../app/jobs/image_analysis_job.rb)
