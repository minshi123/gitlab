# frozen_string_literal: true

require 'rest-client'

module QA
  module Support
    module Api
      HTTP_STATUS_OK = 200
      HTTP_STATUS_CREATED = 201
      HTTP_STATUS_NO_CONTENT = 204
      HTTP_STATUS_ACCEPTED = 202
      HTTP_STATUS_SERVER_ERROR = 500

      def post(url, payload, args = {})
        default_args = {
          method: :post,
          url: url,
          payload: payload,
          verify_ssl: false
        }

        RestClient::Request.execute(
          default_args.merge(args)
        )
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def get(url, args = {})
        default_args = {
          method: :get,
          url: url,
          verify_ssl: false
        }

        RestClient::Request.execute(
          default_args.merge(args)
        )
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def put(url, payload)
        RestClient::Request.execute(
          method: :put,
          url: url,
          payload: payload,
          verify_ssl: false)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def delete(url)
        RestClient::Request.execute(
          method: :delete,
          url: url,
          verify_ssl: false)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def head(url)
        RestClient::Request.execute(
          method: :head,
          url: url,
          verify_ssl: false)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def parse_body(response)
        JSON.parse(response.body, symbolize_names: true)
      end

      def return_response_or_raise(error)
        raise error unless error.respond_to?(:response) && error.response

        error.response
      end
    end
  end
end
