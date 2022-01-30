class BlueprintMechaColor < ApplicationRecord
  belongs_to :color
  belongs_to :blueprint_mecha, foreign_key: "blueprint_id", class_name: "Blueprint::Mecha"
end
