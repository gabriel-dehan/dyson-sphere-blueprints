class MechaUploader < Shrine
  ALLOWED_TYPES  = %w[application/octet-stream].freeze
  MAX_SIZE       = 2.megabyte

  plugin :remote_url, max_size: MAX_SIZE
  plugin :default_url
  plugin :remove_attachment
  plugin :pretty_location
  plugin :validation_helpers

  def generate_location(io, record: nil, **context)
    "store/#{pretty_location(io, record: record, **context)}"
  end

  Attacher.validate do
    # TODO: Mecha validation here?
    validate_size 0..MAX_SIZE
    validate_mime_type_inclusion ALLOWED_TYPES
  end
end
