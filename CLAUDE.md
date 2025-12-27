# CLAUDE.md

## Project Overview

DSP Blueprints is a community website for sharing Dyson Sphere Program (Factorio-like game) blueprints. It's a Rails 6.1 application with a React-based frontend using Stimulus controllers and Webpacker, backed by PostgreSQL and Redis.

## Common Development Commands

### Setup
```bash
# Start with docker-compose (includes PostgreSQL, Redis, S3, SMTP)
docker compose up -d
```

### Testing
```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/blueprint_test.rb

# Run specific test
rails test test/models/blueprint_test.rb:10
```

### Linting
```bash
# Run RuboCop
rubocop

# Auto-fix RuboCop issues
rubocop -a

# Start RuboCop daemon (faster)
rubocop-daemon start
```

### Database
```bash
# Create and migrate database
rails db:create db:migrate

# Rollback last migration
rails db:rollback
```

### Rake Tasks
```bash
# Add a new game version (forces specific version)
rake 'mod:fetch_base_game_latest[0.8.19.7662]'

# Fetch latest game versions from Steam News API
rake mod:fetch_latest

# Flag a version as breaking (use noglob in zsh)
noglob rake 'mod:flag_breaking[Dyson Sphere Program, 0.8.19.7662]'

# Recompute all blueprint data (useful when entities are added/changed)
rake blueprint:recompute_data

# Recompute specific blueprint types
rake blueprint:recompute_mechas
rake blueprint:recompute_factories
rake blueprint:recompute_dyson_spheres
```

## Architecture

### Core Models

**Blueprint Hierarchy (STI)**
- `Blueprint` - Base class with shared functionality
  - `Blueprint::Factory` - Factory blueprints with parsable encoded data
  - `Blueprint::DysonSphere` - Dyson sphere blueprints
  - `Blueprint::Mecha` - Mecha blueprints

All blueprints:
- Belong to a `Collection` and `Mod`
- Use `friendly_id` for slugs
- Support voting via `acts_as_votable`
- Support tagging via `acts_as_taggable_on`
- Have rich text descriptions and multiple pictures
- Default scope filters to "Dyson Sphere Program" mod only

**Mod System**
- `Mod` model manages game versions and compatibility
- Stores version data as JSON with breaking change flags
- `compatibility_range_for(version)` returns compatible version range
- Only "Dyson Sphere Program" mod is actively used (legacy mods exist but are hidden)

### Blueprint Parsing

Blueprint parsing happens via background jobs:
1. User uploads encoded blueprint string
2. Validation occurs in model via `Parsers::*Blueprint` classes
3. `BlueprintParserJob` decodes and extracts summary data asynchronously
4. Parsers live in `lib/parsers/` and use the `dsp_blueprint_parser` gem

Parser classes:
- `Parsers::FactoryBlueprint`
- `Parsers::DysonSphereBlueprint`
- `Parsers::MechaBlueprint`
- `Parsers::MultibuildBetaBlueprint` (legacy)

### Frontend Architecture

Uses Stimulus controllers (not React - Stimulus is a lightweight JS framework):
- Controllers in `app/javascript/controllers/`
- Blueprint parsing UI: `factoryBlueprintParser_controller.js`, `dysonSphereBlueprintParser_controller.js`
- 3D preview uses `brokenmass3dpreview` package
- File uploads use Uppy.js via `fileUpload.js`

### Image Handling

- Uses Shrine gem for file uploads
- Images stored in AWS S3 with CloudFront CDN
- Development supports localstack for S3 emulation
- `PictureUploader` handles cover pictures and additional pictures

### Authorization

- Devise for authentication (with Discord OAuth)
- Pundit for authorization policies (in `app/policies/`)

### Background Jobs

Sidekiq jobs in `app/jobs/`:
- `BlueprintParserJob` - Parses and extracts blueprint data
- `BaseGameManagerJob` - Fetches game versions from Steam
- `ModManagerJob` - Manages mod versions
- `MechaColorExtractJob` - Extracts color data from mecha blueprints

## Important Patterns

### Blueprint STI

The codebase uses Single Table Inheritance for blueprints. When working with blueprints:
- Always use specific classes (`Blueprint::Factory`, not generic `Blueprint`)
- The `type` column determines the class
- `find_sti_class` is overridden to prefix with `Blueprint::`
- Each type has its own controller in `app/controllers/blueprint/`

### Mod Version Compatibility

The `Mod#compatibility_range_for` method is complex but critical:
- Takes a version string and returns `[min_version, max_version]`
- Considers "breaking" flags in version JSON
- Blueprint compatibility is shown based on this range
- Breaking changes create hard boundaries for compatibility

### Large Blueprints

Blueprints over 700KB are considered "large":
- `Blueprint#large_bp?` checks encoded blueprint size
- Large blueprints may have special handling for performance
- The `light_query` scope excludes `encoded_blueprint` column to reduce data transfer

### Default Scopes

Both `Blueprint` and `Mod` have default scopes filtering to "Dyson Sphere Program". This hides legacy MultiBuild data. Be aware when:
- Writing migrations
- Using `unscoped` to bypass filters
- Debugging why certain records don't appear

## Testing

Tests use Rails' default Minitest framework:
- Model tests in `test/models/`
- Controller tests in `test/controllers/`
- System tests for end-to-end scenarios

## Environment Setup

Copy `.env.sample` to `.env` for local development. Key variables:
- `DISCORD_CLIENT_ID` / `DISCORD_CLIENT_SECRET` - OAuth (optional for most work)
- AWS credentials - Required for image upload/display
- Can use docker-compose for full local environment with localstack S3

## Code Style

RuboCop configuration in `.rubocop.yml`:
- Double quotes for strings
- Expanded empty methods
- No frozen string literal comments
- Hash rockets aligned in table style
- Many metrics cops disabled for flexibility

## IMPORTANT:

- Hosted on HEROKU
- CRITICAL: Never run rails commands on heroku, never seed the database on heroku. Always ask the user to run them manually.
