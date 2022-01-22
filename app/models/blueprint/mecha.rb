class Blueprint::Mecha < Blueprint
  def self.sti_name; "Mecha"; end
  def normalize_friendly_id(string); "mecha-#{super}"; end

  include MechaUploader::Attachment(:blueprint_file)

  after_save :decode_blueprint
  validate :encoded_blueprint_parsable

  def large_bp?
    return false unless blueprint_file_data

    blueprint_file.size > 500.kilobyte
  end

  private

  def decode_blueprint
    BlueprintParserJob.perform_now(id) if saved_change_to_attribute?(:blueprint_file_data)
  end

  def encoded_blueprint_parsable
    if saved_change_to_attribute?(:blueprint_file_data)
      valid = Parsers::MechaBlueprint.new(self).validate

      errors.add(:blueprint_file_data, "Wrong mecha blueprint format for mod version: #{mod.name} - #{mod_version}") if !valid
    end
  end
end
