{ pkgs, lib, config, ... }:

{
  # --- Language runtimes ---
  languages.ruby = {
    enable = true;
    version = "3.2.9";
    bundler.enable = false; # We install bundler 2.4.19 manually via task below
  };

  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22; # LTS; NODE_OPTIONS=--openssl-legacy-provider handles webpacker 5
    yarn.enable = true;
    yarn.package = pkgs.yarn;
  };

  # --- System packages needed by native gem extensions ---
  packages = [
    pkgs.imagemagick       # image_processing gem uses MiniMagick
    pkgs.libpq             # pg gem native extension
    pkgs.shared-mime-info  # marcel gem MIME detection
    pkgs.libyaml           # psych gem (Ruby YAML)
    pkgs.zlib
    pkgs.openssl
    pkgs.libxml2           # nokogiri
    pkgs.libxslt           # nokogiri
    pkgs.pkg-config
    pkgs.chromium          # system tests (capybara + selenium)
    pkgs.chromedriver
    pkgs.overmind          # Procfile runner (runs web + worker from Procfile)
    pkgs.python3           # ministack runs in an isolated Python venv
    pkgs.awscli2           # ensure local S3 buckets exist on shell entry
  ];

  # --- Services (replaces docker-compose postgres + redis) ---
  services.postgres = {
    enable = true;
    port = 5432;
    listen_addresses = "127.0.0.1";
    initialDatabases = [
      { name = "dspblueprints_development"; }
      { name = "dspblueprints_test"; }
    ];
    initialScript = "CREATE USER dev WITH PASSWORD 'password' SUPERUSER CREATEDB;";
  };

  services.redis = {
    enable = true;
    port = 6379;
  };

  # --- Processes (replaces docker-compose localstack + mailhog) ---
  # Mailhog — SMTP on :1025, Web UI on :8025
  processes.mailhog = {
    exec = "${pkgs.mailhog}/bin/MailHog";
  };

  # MiniStack S3 — drop-in LocalStack replacement (same port 4566, same S3 API)
  # Installed in an isolated venv so it doesn't pollute the project environment.
  processes.ministack = {
    exec = ''
      VENV="$DEVENV_STATE/ministack-venv"
      if [ ! -x "$VENV/bin/ministack" ]; then
        ${pkgs.python3}/bin/python3 -m venv "$VENV"
        "$VENV/bin/pip" install --quiet ministack
      fi
      export DEFAULT_REGION=eu-west-1
      export PERSIST_STATE=1
      export STATE_DIR="$DEVENV_STATE/ministack-state"
      export S3_PERSIST=1
      export S3_DATA_DIR="$DEVENV_STATE/ministack-s3"
      export DISABLE_CORS_CHECKS=1
      "$VENV/bin/ministack"
    '';
  };

  # --- Environment variables (from .env.sample defaults) ---
  env = {
    PG_USER = "dev";
    PG_PASS = "password";
    PG_HOST = "127.0.0.1";
    REDISCLOUD_URL = "redis://127.0.0.1:6379/0";
    AWS_S3_ACCESS_ID_KEY = "test";
    AWS_S3_ACCESS_SECRET_KEY = "test";
    AWS_S3_REGION = "eu-west-1";
    AWS_S3_BUCKET = "dyson-sphere-blueprints";
    AWS_S3_ENDPOINT = "http://localhost:4566";
    NODE_OPTIONS = "--openssl-legacy-provider";
    # Spring doesn't play well with Nix-managed environments
    DISABLE_SPRING = "1";
  };

  # --- Tasks (run automatically before shell entry) ---
  tasks."deps:bundler" = {
    exec = "gem install bundler -v 2.4.19 --no-document";
    before = [ "devenv:enterShell" ];
  };

  tasks."deps:bundle" = {
    exec = "bundle install";
    after = [ "deps:bundler" ];
    before = [ "devenv:enterShell" ];
  };

  tasks."deps:yarn" = {
    exec = "yarn install";
    before = [ "devenv:enterShell" ];
  };
}
