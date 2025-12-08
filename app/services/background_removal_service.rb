class BackgroundRemovalService
  class RemovalError < StandardError; end

  def initialize(image_path)
    @image_path = image_path
  end

  def remove_background
    # Output path for the processed image
    output_path = @image_path.to_s.sub(/\.\w+$/, '_nobg.png')

    # Command: .venv/bin/rembg i input.png output.png
    # Use absolute path to venv to be safe or relative from root
    rembg_path = Rails.root.join('.venv', 'bin', 'rembg')
    
    stdout, stderr, status = Open3.capture3(rembg_path.to_s, 'i', @image_path.to_s, output_path)

    if status.success? && File.exist?(output_path)
      return output_path
    else
      Rails.logger.error("Background Removal Failed: #{stderr}")
      return nil
    end
  rescue => e
    Rails.logger.error("Background Removal Error: #{e.message}")
    nil
  end
end
