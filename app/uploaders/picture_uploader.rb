require "image_processing/mini_magick"

class PictureUploader < Shrine
  ALLOWED_TYPES  = %w[image/jpeg image/jpg image/png image/webp]
  MAX_SIZE       = 3.megabyte
  MAX_DIMENSIONS = [4000, 4000]

  DERIVATIVES = {
    small:  [100, 100],
    medium: [262, 200],
    large:  [880, 495],
  }

  plugin :remove_attachment
  plugin :pretty_location
  plugin :validation_helpers
  plugin :store_dimensions, log_subscriber: nil
  plugin :derivation_endpoint, prefix: "derivations/image"

  Attacher.validate do
    validate_size 0..MAX_SIZE

    if validate_mime_type_inclusion ALLOWED_TYPES
      validate_max_dimensions MAX_DIMENSIONS
    end
  end

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)

    THUMBNAILS.transform_values do |(width, height)|
      magick.convert("jpg").resize_to_fill!(width, height),
    end
  end

  derivation :thumbnail do |file, width, height|
    magick = ImageProcessing::MiniMagick.source(file)
    magick..convert("jpg").resize_to_fill!(width.to_i, height.to_i)
  end
end