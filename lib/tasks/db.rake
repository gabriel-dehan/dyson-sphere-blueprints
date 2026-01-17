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

  task import_from_existing_dump: [:environment, :create] do
    config = db_config
    env = { "PGPASSWORD" => config[:password] }
    puts "[1/1] Mounting backup on local database"
    system(env, "pg_restore", "--clean", "--verbose", "--no-acl", "--no-owner",
           "--host", config[:host], "--username", config[:username], "--dbname", config[:database],
           "tmp/latest.dump")
    puts "Done."
  end

  desc "Dumps the database to db/APP_NAME.dump"
  task dump: :environment do
    config = db_config
    env = { "PGPASSWORD" => config[:password] }
    cmd = "pg_dump --host #{config[:host]} --username #{config[:username]} --verbose --clean --no-owner --no-acl --format=c #{config[:database]} > #{Rails.root}/db/#{config[:app]}.dump"
    puts cmd
    system(env, cmd)
  end

  desc "Dumps and compresses the database to db/APP_NAME.dump.gz"
  task dump_compressed: :environment do
    config = db_config
    env = { "PGPASSWORD" => config[:password] }
    cmd = "pg_dump --host #{config[:host]} --username #{config[:username]} --verbose --clean --no-owner --no-acl --format=c #{config[:database]} | gzip > #{Rails.root}/db/#{config[:app]}.dump.gz"
    puts cmd
    system(env, cmd)
  end

  desc "Restores the database dump at db/APP_NAME.dump."
  task restore: :environment do
    abort "Refusing to restore dump in production." if Rails.env.production?

    config = db_config
    env = { "PGPASSWORD" => config[:password] }
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    cmd = "pg_restore --verbose --host #{config[:host]} --username #{config[:username]} --clean --no-owner --no-acl --dbname #{config[:database]} #{Rails.root}/db/#{config[:app]}.dump"
    puts cmd
    system(env, cmd)
  end

  desc "Restores the compressed dump at db/APP_NAME.dump.gz."
  task restore_compressed: :environment do
    abort "Refusing to restore compressed dump in production." if Rails.env.production?

    config = db_config
    env = { "PGPASSWORD" => config[:password] }
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    cmd = "gunzip -c #{Rails.root}/db/#{config[:app]}.dump.gz | pg_restore --verbose --host #{config[:host]} --username #{config[:username]} --clean --no-owner --no-acl --dbname #{config[:database]}"
    puts cmd
    system(env, cmd)
  end

  desc "Anonymizes sensitive data in the database"
  task anonymize: :environment do
    abort "Refusing to anonymize in production." if Rails.env.production?

    puts "Anonymizing users..."
    User.find_each do |user|
      puts "Anonymizing User##{user.id} (#{user.username})..."
      user.username = unique_value(User, :username, "user#{user.id}", exclude_id: user.id)
      user.email = unique_value(User, :email, "user#{user.id}@example.invalid", exclude_id: user.id)
      user.password = "password"
      user.password_confirmation = "password"
      user.reset_password_token = nil
      user.reset_password_sent_at = nil
      user.remember_created_at = nil
      user.current_sign_in_at = nil
      user.last_sign_in_at = nil
      user.current_sign_in_ip = nil
      user.last_sign_in_ip = nil
      user.provider = nil
      user.uid = nil
      user.discord_avatar_url = nil
      user.token = nil
      user.token_expiry = nil
      user.save!(validate: false)
    end

    puts "Scrubbing attachment filenames..."
    scrub_shrine_metadata(Blueprint, :cover_picture_data, prefix: "cover")
    scrub_shrine_metadata(Blueprint, :blueprint_file_data, prefix: "blueprint")
    scrub_shrine_metadata(Picture, :picture_data, prefix: "picture")
    scrub_active_storage_filenames

    puts "Done."
  end

  desc "Hides private information in the database"
  task privatize: :environment do
    Rake::Task["db:anonymize"].invoke
  end

  private

  def db_config
    config = Rails.configuration.database_configuration[Rails.env]
    {
      app: Rails.application.class.module_parent_name.underscore,
      host: config["host"] || "localhost",
      database: config["database"],
      username: config["username"] || config["user"] || ENV["PG_USER"] || "dev",
      password: config["password"] || ENV["PG_PASS"] || "password",
    }
  end

  def with_config
    config = db_config
    yield config[:app], config[:host], config[:database], config[:username]
  end

  def scrub_shrine_metadata(scope, column, prefix:)
    scope.find_each do |record|
      data = record.public_send(column)
      next if data.blank?

      parsed = begin
        JSON.parse(data)
      rescue StandardError
        nil
      end
      next unless parsed.is_a?(Hash)

      metadata = parsed["metadata"] || {}
      filename = metadata["filename"].to_s
      next if filename.empty?

      ext = File.extname(filename)
      metadata["filename"] = "#{prefix}-#{record.id}#{ext}"
      parsed["metadata"] = metadata
      record.update_column(column, parsed.to_json)
    end
  end

  def scrub_active_storage_filenames
    return unless defined?(ActiveStorage::Blob)

    ActiveStorage::Blob.find_each do |blob|
      filename = blob.filename.to_s
      ext = File.extname(filename)
      blob.update!(filename: "file-#{blob.id}#{ext}")
    end
  end

  def unique_value(scope, column, base, exclude_id:)
    value = base
    relation = scope.where.not(id: exclude_id)

    if base.include?("@")
      local, domain = base.split("@", 2)
      value = "#{local}-#{SecureRandom.hex(3)}@#{domain}" while relation.exists?(column => value)
    else
      value = "#{base}-#{SecureRandom.hex(3)}" while relation.exists?(column => value)
    end

    value
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
