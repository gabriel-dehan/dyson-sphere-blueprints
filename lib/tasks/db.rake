namespace :db do
  desc "Backs up heroku database and restores it locally."
  task import_from_heroku: [ :environment, :create ] do
    HEROKU_APP_NAME = 'dyson-sphere-blueprints' # Change this if app name is not picked up by `heroku` git remote.

    c = Rails.configuration.database_configuration[Rails.env]
    heroku_app_flag = HEROKU_APP_NAME ? " --app #{HEROKU_APP_NAME}" : nil
    Bundler.with_clean_env do
      puts "[1/4] Capturing backup on Heroku"
      `heroku pg:backups capture DATABASE_URL#{heroku_app_flag}`
      puts "[2/4] Downloading backup onto disk"
      `curl -o tmp/latest.dump \`heroku pg:backups public-url #{heroku_app_flag} | cat\``
      puts "[3/4] Mounting backup on local database"
      `pg_restore --clean --verbose --no-acl --no-owner -h localhost -d #{c["database"]} tmp/latest.dump`
      puts "[4/4] Removing local backup"
      `rm tmp/latest.dump`
      puts "Done."
    end
  end
end