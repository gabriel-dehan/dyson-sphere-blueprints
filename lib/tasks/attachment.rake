namespace :attachment do
  desc "Migrate from cloudinary to s3"
  task migrate: [ :environment ] do
    bp = Blueprint.first
    ap bp.cover.url
    bp.cover_picture_remote_url = bp.cover.url
    bp.save!

  end
end