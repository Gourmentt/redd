require "uri"
require_relative "base"

module Redd
  module Clients
    # The client for a web-based flow (e.g. "login with reddit")
    class Web < Base
      # @!attribute [r] client_id
      attr_reader :client_id

      # @!attribute [r] redirect_uri
      attr_reader :redirect_uri

      # @param [Hash] options The options to create the client with.
      # @see Base#initialize
      # @see Redd.it
      def initialize(client_id, secret, redirect_uri, **options)
        @client_id = client_id
        @secret = secret
        @redirect_uri = redirect_uri
        super(**options)
      end

      # @param [String] state A random string to double-check later.
      # @param [Array<String>] scope The scope to request access to.
      # @param [:temporary, :permanent] duration
      # @return [String] The url to redirect the user to.
      def auth_url(state, scope = ["identity"], duration = :temporary)
        query = {
          response_type: "code",
          client_id: @client_id,
          redirect_uri: @redirect_uri,
          state: state,
          scope: scope.join(","),
          duration: duration
        }

        url = URI.join(auth_endpoint, "/api/v1/authorize")
        url.query = URI.encode_www_form(query)
        url.to_s
      end

      # Authorize using the code given.
      # @param [String] code The code from the get params.
      # @return [Access] The access given by reddit.
      def authorize!(code)
        response = auth_connection.post(
          "/api/v1/access_token",
          grant_type: "authorization_code",
          code: code,
          redirect_uri: @redirect_uri
        )

        @access = Access.new(response.body)
      end
    end
  end
end
