namespace :mod do
  desc "Fetches the latest versions of all managed mods"
  task fetch_latest: :environment do
    ModManagerJob.perform_later
  end
end
