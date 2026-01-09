# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Handles HTTP communication with the AutoDNS REST API
    class Connection
      BASE_URL = "https://api.autodns.com/v1"
      DEMO_URL = "https://api.demo.autodns.com/v1"

      attr_reader :url, :context, :debug

      def initialize(url:, username:, password:, context: "4", debug: false)
        @url = url
        @username = username
        @password = password
        @context = context.to_s
        @debug = debug
      end

      # HTTP methods that delegate to Faraday
      %i[get post put patch delete].each do |method|
        define_method(method) do |path, body: nil, params: {}|
          request(method, path, body: body, params: params)
        end
      end

      def test_connection
        response = get("hello")
        response[:status] == "success"
      rescue Error
        false
      end

      private

      def connection
        @connection ||= Faraday.new(url: @url) do |f|
          f.request :json
          f.response :json
          f.adapter Faraday.default_adapter
          f.headers["User-Agent"] = "autodns-domainrobot_api/#{VERSION}"
          f.headers["X-Domainrobot-Context"] = @context
          f.headers["Authorization"] = "Basic #{Base64.strict_encode64("#{@username}:#{@password}")}"
        end
      end

      def request(method, path, body: nil, params: {})
        warn "[DEBUG] #{method.upcase} #{@url}/#{path}" if @debug

        response = connection.public_send(method, path) do |req|
          req.body = body if body
          req.params = params if params.any?
        end

        handle_response(response)
      rescue Faraday::Error => e
        raise Error, "HTTP request failed: #{e.message}"
      end

      def handle_response(response)
        case response.status
        when 200..299
          parse_response(response)
        when 401
          raise AuthenticationError, "Invalid credentials"
        when 404
          raise NotFoundError, "Resource not found"
        when 429
          raise RateLimitError, "Rate limit exceeded (3 requests/second)"
        else
          error_message = extract_error_message(response)
          raise Error, "API error (#{response.status}): #{error_message}"
        end
      end

      def parse_response(response)
        body = response.body
        return { data: [], status: nil } unless body.is_a?(Hash)

        {
          status: body.dig("status", "type"),
          status_text: body.dig("status", "text"),
          stid: body["stid"],
          data: body["data"] || [],
          object: body["object"],
          ctid: body["ctid"]
        }
      end

      def extract_error_message(response)
        if response.body.is_a?(Hash)
          response.body.dig("status", "text") ||
            response.body.dig("messages")&.first&.dig("text") ||
            response.body.to_s
        else
          response.body.to_s
        end
      end
    end
  end
end
