class RenameBlueprintColumnDecodedBlueprintDataToSummary < ActiveRecord::Migration[6.1]
  def change
    rename_column :blueprints, :decoded_blueprint_data, :summary

    Blueprint.all.each do |blueprint|
      Parsers::MultibuildBetaBlueprint.new(blueprint).parse!(silent_errors: false)
    end
  end
end
