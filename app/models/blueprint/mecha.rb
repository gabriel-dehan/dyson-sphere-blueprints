class Blueprint::Mecha < Blueprint
  def self.sti_name; "Mecha"; end
  def normalize_friendly_id(string); "mecha-#{super}"; end

  include MechaThumbnailUploader::Attachment(:cover_picture)
  include MechaUploader::Attachment(:blueprint_file)
  acts_as_votable

  has_many :blueprint_mecha_colors, dependent: :destroy, foreign_key: 'blueprint_id'
  has_many :colors, through: :blueprint_mecha_colors

  after_save :decode_blueprint
  after_save :extract_colors

  validates :blueprint_file, presence: true
  validate :blueprint_file_valid
  # validates :additional_pictures, length: { minimum: 1, message: "Missing an additional picture, please provide at least one." }

  def large_bp?
    return false unless blueprint_file_data

    blueprint_file.size > 500.kilobyte
  end

  private

  def decode_blueprint
    BlueprintParserJob.perform_now(id) if saved_change_to_attribute?(:blueprint_file_data)
  end

  def extract_colors
    MechaColorExtractJob.perform_now(id) if saved_change_to_attribute?(:blueprint_file_data)
  end

  def blueprint_file_valid
    if !id || will_save_change_to_attribute?(:blueprint_file_data)
      if blueprint_file
        valid = Parsers::MechaFile.validate(blueprint_file.download)
      else
        valid = false
      end
      errors.add(:blueprint_file, "Wrong mecha blueprint format for game version: #{mod.name} - #{mod_version}") if !valid
    end
  end
end
