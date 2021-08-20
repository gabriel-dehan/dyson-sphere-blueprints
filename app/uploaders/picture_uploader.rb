require "image_processing/mini_magick"

class PictureUploader < Shrine
  ALLOWED_TYPES  = %w[image/jpeg image/jpg image/png image/webp].freeze
  MAX_SIZE       = 3.megabyte
  MAX_DIMENSIONS = [4000, 4000].freeze

  DERIVATIVES = {
    small: [100, 100],
    medium: [262, 200],
    large: [880, 495],
  }.freeze

  plugin :remote_url, max_size: 5.megabyte
  plugin :default_url
  plugin :remove_attachment
  plugin :pretty_location
  plugin :validation_helpers
  plugin :store_dimensions, log_subscriber: nil
  plugin :derivation_endpoint, prefix: "derivations/image"

  def generate_location(io, record: nil, **context)
    "store/#{pretty_location(io, record: record, **context)}"
  end

  Attacher.validate do
    validate_size 0..MAX_SIZE

    validate_max_dimensions MAX_DIMENSIONS if validate_mime_type_inclusion ALLOWED_TYPES
  end

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)

    DERIVATIVES.transform_values do |(width, height)|
      magick.convert("jpg").resize_to_fill!(width, height)
    end
  end

  derivation :thumbnail do |file, width, height|
    magick = ImageProcessing::MiniMagick.source(file)
    magick.convert("jpg").resize_to_fill!(width.to_i, height.to_i)
  end

  Attacher.default_url do |derivative: nil, **|
    url if derivative
  end
end
