class User < ApplicationRecord
  has_many :preferences
  before_destroy :revoke_token
  after_create :create_preferences

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:memair]

  def admin?
    email_domain = self.email.split("@").last
    ['gho.st', 'memair.com'].include? email_domain
  end

  def self.from_memair_omniauth(omniauth_info)
    data        = omniauth_info.info
    credentials = omniauth_info.credentials

    user = User.where(email: data['email']).first

    unless user
     user = User.create(
       email:    data['email'],
       password: Devise.friendly_token[0,20]
     )
    end

    user.memair_access_token = credentials['token']
    user.save
    user
  end

  def create_preferences
    Channel.all.each do |channel|
      Preference.create(
        user: self,
        channel: channel,
        frequency: channel.default_frequency
      )
    end
  end

  private
    def revoke_token
      user = Memair.new(self.memair_access_token)
      query = 'mutation {RevokeAccessToken{revoked}}'
      user.query(query)
    end
end
