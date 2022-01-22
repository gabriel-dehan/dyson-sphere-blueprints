class Blueprint::DysonSphere < Blueprint
  def self.sti_name; "DysonSphere"; end
  def normalize_friendly_id(string); "dyson-sphere-#{super}"; end

  # Pictures
  include PictureUploader::Attachment(:cover_picture)

  after_save :decode_blueprint

  validates :cover_picture, presence: true
  validates :encoded_blueprint, presence: true
  validate :encoded_blueprint_parsable

  def large_bp?
    return false unless encoded_blueprint

    encoded_blueprint.size > 700_000
  end

  private

  def decode_blueprint
    BlueprintParserJob.perform_now(id) if saved_change_to_attribute?(:encoded_blueprint)
  end

  def encoded_blueprint_parsable
    if saved_change_to_attribute?(:encoded_blueprint)
      valid = Parsers::DysonSphereBlueprint.new(self).validate
      errors.add(:encoded_blueprint, "Wrong blueprint format for mod version: #{mod.name} - #{mod_version}") if !valid
    end
  end
end
