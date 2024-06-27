namespace :db do
  desc "Backs up heroku database and restores it locally."
  task import_from_heroku: [:environment, :create] do
    app_name = "dyson-sphere-blueprints" # Change this if app name is not picked up by `heroku` git remote.

    c = Rails.configuration.database_configuration[Rails.env]
    heroku_app_flag = app_name ? " --app #{app_name}" : nil
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

  desc "Dumps the database to db/APP_NAME.dump"
  task dump: :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}.dump"
    end
    puts cmd
    exec cmd
  end

  desc "Restores the database dump at db/APP_NAME.dump."
  task restore: :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{app}.dump"
    end
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    puts cmd
    exec cmd
  end

  desc "Hides private information in the database"
  task privatize: :environment do
    if Rails.env.development? # Don't want that in production whatever the reason
      User.all.each do |u|
        puts "Privatizing User##{u.id} (#{u.username})..."
        u.username = "User##{u.id}"
        u.email = "user##{u.id}@test.com"
        u.password = "password"
        u.password_confirmation = "password"
        u.save!
      end
      puts "Done."
    end
  end

  private

  def with_config
    yield Rails.application.class.module_parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end

  desc "Analyze and reindex the database"
  task analyze_and_reindex: :environment do
    puts "Analyzing database..."
    ActiveRecord::Base.connection.execute("ANALYZE;")
    puts "Reindexing database..."
    ActiveRecord::Base.connection.execute("REINDEX DATABASE #{ActiveRecord::Base.connection.current_database};")
    puts "Done!"
  end
end
