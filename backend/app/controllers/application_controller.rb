class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = authenticate_from_token
  end

  def authenticate_from_token
    token = request.headers["Authorization"]&.split(" ")&.last
    return nil if token.blank?

    payload = JsonWebToken.decode(token)
    return nil unless payload

    User.find_by(id: payload[:user_id])
  end

  def render_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
