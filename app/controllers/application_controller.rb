class ApplicationController < ActionController::API

  # include ActionController::RequestForgeryProtection
  #
  # protect_from_forgery with: :null_session
  # Our JSON API will be authenticated using JWT tokens, so we wont need Rails's CSRF protection
  # to throw an exception when the CSRF token is missing, we'll instruct Rails to use a null session
  # instead.

  # CSRF is usually checked on non-GET requests, and by default if no CSRF token is provided Rails will
  # throw an exception, causing our requests to fail. The :null_session setting will clear out our session
  # variables instead of causing an exception to be thrown.

  respond_to :json

  # before_action :underscore_params!
  # filter to convert incoming parameters to snake_case

  before_action :configure_permitted_parameters, if: :devise_controller?
  # Since we are using custom/additonal parameters, we have to get Devise to accept them

  before_action :authenticate_user
  #

    private
    # private methods means we can't mistakenly use them as controller actions which
    # usually require something to be rendered

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    end

    def authenticate_user
      if request.headers['Authorization'].present?
        authenticate_or_request_with_http_token do |token|
          begin
            jwt_payload = JWT.decode(token, Rails.application.secrets.secret_key_base).first

            @current_user_id = jwt_payload['id']
          rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
            head :unauthorized
          end
        end
      end
    end

    # Here I create a method for authenticating users with JWT tokens. Incoming requests are
    # checked for an authorisation header. authenticate_or_request_with_http_token grabs token from auth
    # header if it is in JWT format. Next an attempt is made to decode token. If it fails an exception
    # is raised and the token is 'rescued' resulting in an error (401) back to React-Native
    # Decode method also throws exceptions for expired tokens. If the token is successfully decoded
    # the ID is grabbed from the payload and set to the current user ID for later use. We can then
    # use this value for all controllers due to inheritance.


    # OVERRIDE Devise's authenticate_user!, current_user & signed_in? methods
    # Allows us to access current_user & signed_in? throughout our app
    # as if we were using Devise without JWTs

    def authenticate_user!(options = {})
      head :unauthorized unless signed_in?
    end

    def current_user
      @current_user ||= super || User.find(@current_user_id)
    end

    def signed_in?
      @current_user_id.present?
    end

    # def underscore_params!
    #   params.deep_transform_keys!(&:underscore)
    # end
 
    # This ^ is commented out as I feel it need to be talking to front end to function
    # appropiately as I'm getting an error stated it isnt declared. After soem research
    # it may be deprecated. See config/json_param_key_transform.rb for deets
  end
