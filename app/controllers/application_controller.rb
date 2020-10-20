class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_request

  private

  # https://ropesec.com/articles/timing-attacks/
  # https://thoughtbot.com/blog/token-authentication-with-rails
  # https://stackoverflow.com/questions/17712359/authenticate-or-request-with-http-token-returning-html-instead-of-json
  def request_http_token_authentication(realm = "Application", message = nil)
    self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
    render json: {errors: ["status"=>"401", "title"=>"Unauthorized", "detail"=>"Api key credential is missing, disabled, or invalid."]}, status: :unauthorized
  end

  def authenticate_request
    authenticate_or_request_with_http_token do |token, options|
      api_key = ApiKey.find_by(access_token: token)
      secret_key = ApiKey.find(api_key.id).secret_key
      api_key.present? && (api_key.active != false) && secure_compare_with_hashing(api_key.secret_key, secret_key)
    end
  end

  def secure_compare_with_hashing(key1, key2)
    ActiveSupport::SecurityUtils.secure_compare(key1, key2)
  end
end
