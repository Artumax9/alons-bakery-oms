require "net/http"
require "uri"

module Webhooks
  # Wraps the raw HTTP POST so the job doesn't know about Net::HTTP and so it
  # can be stubbed in tests.
  class Client
    class DeliveryError < StandardError; end

    def initialize(url)
      @url = url
    end

    def post(payload)
      raise ArgumentError, "missing webhook url" if @url.blank?

      uri = URI.parse(@url)
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = payload.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      return response if response.is_a?(Net::HTTPSuccess)

      raise DeliveryError, "n8n responded #{response.code}"
    rescue SocketError, Errno::ECONNREFUSED, Timeout::Error => e
      raise DeliveryError, e.message
    end
  end
end
