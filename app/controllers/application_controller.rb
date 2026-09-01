class ApplicationController < ActionController::API
  # Centralized error handling: every failure leaves the API as
  # { "errors": [ "..." ] } with a sensible status code, so the SPA has one
  # shape to parse.
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  def render_not_found(exception)
    render json: { errors: [ exception.message ] }, status: :not_found
  end

  def render_bad_request(exception)
    render json: { errors: [ exception.message ] }, status: :bad_request
  end

  # Shared-token guard for the admin (Alondra's panel) endpoints. The SPA sends
  # ADMIN_TOKEN in the X-Admin-Token header. secure_compare runs in constant
  # time so the token can't be guessed one character at a time from timing.
  def require_admin
    provided = request.headers["X-Admin-Token"].to_s
    expected = ENV["ADMIN_TOKEN"].to_s

    return if expected.present? &&
              ActiveSupport::SecurityUtils.secure_compare(provided, expected)

    render json: { errors: [ "unauthorized" ] }, status: :unauthorized
  end
end
