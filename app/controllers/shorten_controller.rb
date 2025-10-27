# it's api controller
class ShortenController < ActionController::API
  rescue_from StandardError do |e|
    render json: { error: e.message }, status: :internal_server_error
  end
  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :bad_request
  end
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: "Record not found" }, status: :not_found
  end

  before_action :params_trim
  before_action :validate_url, only: %i(decode)

  def encode
    url = Url.find_by(origin_url: url_params[:url]) || Url.create!(origin_url: url_params[:url])
    code = ShortenUrlService.encode(url.origin_url.length, url.id)
    render json: {
      short_url: "#{request.base_url}/#{code}"
    }, status: :created
  end

  def decode
    code = url_params[:url].split("/").last
    url_id = ShortenUrlService.decode(code)
    render json: {
      origin_url: Url.find(url_id).origin_url
    }, status: :ok
  end

  private

  def url_params
    params.permit(:url)
  end

  def params_trim
    params.each do |key, value|
      params[key] = value.strip if value.respond_to?(:strip)
    end
  end

  def validate_url
    url = url_params[:url]
    uri = URI.parse(url)
    domain = ENV.fetch("DOMAIN_NAME", "localhost")
    raise URI::InvalidURIError unless (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && uri.host == domain
  rescue URI::InvalidURIError
    render json: { error: "URL is invalid" }, status: :bad_request
  end
end
