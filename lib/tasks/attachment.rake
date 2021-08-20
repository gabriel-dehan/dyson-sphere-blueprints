namespace :attachment do
  desc "Migrate from cloudinary to s3"
  task migrate: [:environment] do
    Blueprint.all.each do |bp|
      puts "Migrating #{bp.id}"
      bp.cover_picture_remote_url = bp.cover.url if !bp.cover_picture

      bp.pictures.each do |picture|
        a_picture = bp.additional_pictures.new
        a_picture.picture_remote_url = picture.url
        a_picture.save!
      end

      bp.save!
    end
  end
end
