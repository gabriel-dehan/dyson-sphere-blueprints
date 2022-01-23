class Engine::Mecha
  def initialize(file)
    @mecha_file = file
  end

  def extract_image
    PngExtractor.extract(@mecha_file, nil, tmp: true)
  end
end
