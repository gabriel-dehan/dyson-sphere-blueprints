class User < ApplicationRecord
  acts_as_voter

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:discord]

  has_many :collections, dependent: :destroy
  has_many :blueprints, through: :collections
  has_many :factory_blueprints, through: :collections, dependent: :destroy, class_name: "Blueprint::Factory"
  has_many :dyson_sphere_blueprints, through: :collections, dependent: :destroy, class_name: "Blueprint::DysonSphere"
  has_many :mecha_blueprints, through: :collections, dependent: :destroy, class_name: "Blueprint::Mecha"
  has_many :blueprint_usage_metrics, dependent: :destroy
  has_many :used_blueprints, through: :blueprint_usage_metrics, source: :blueprint

  before_create :create_default_collections

  validates :username, uniqueness: true

  def admin?
    role == "admin"
  end

  def self.find_for_discord_oauth(auth)
    user_params = auth.slice("provider", "uid")
    user_params[:email] = auth.info.email
    user_params[:username] = auth.info.name
    user_params[:discord_avatar_url] = auth.info.image
    user_params[:token] = auth.credentials.token
    user_params[:token_expiry] = Time.zone.at(auth.credentials.expires_at)
    user_params = user_params.to_h

    user = User.find_by(provider: auth.provider, uid: auth.uid)
    user ||= User.find_by(email: auth.info.email) # User did a regular sign up in the past.
    if user
      # if the user already has a username we don't change it
      user_params.delete("username")
      user.update(user_params)
    else
      user = User.new(user_params)
      user.password = Devise.friendly_token[0, 20]  # Fake password for validation
      user.save
    end

    user
  end

  private

  def create_default_collections
    collections.new(name: "Public", type: "Public")
    collections.new(name: "Private", type: "Private")
    collections.new(name: "Mechas", type: "Public", category: "mechas")
    collections.new(name: "Factories", type: "Public", category: "factories")
    collections.new(name: "Dyson Spheres", type: "Public", category: "dyson_spheres")
  end
end
