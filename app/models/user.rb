class User < ApplicationRecord


  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  validates :username, uniqueness: { case_sensitive: true },                                                 
                             presence: true,
                             allow_blank: false

  # validation for usernames

def generate_jwt
  JWT.encode({ id: id,
    exp: 60.days.from_now.to_i },
    Rails.application.secrets.secret_key_base)
end

# Generates JWT tokens. Payload has id of user, expiration time & a secret key to sign our JWT tokens

end
