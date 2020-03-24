# frozen_string_literal: true

module Gitlab
  module Geo
    class GitPushSSHProxy
      HTTP_READ_TIMEOUT = 60

      UPLOAD_PACK_REQUEST_CONTENT_TYPE = 'application/x-git-upload-pack-request'.freeze
      UPLOAD_PACK_RESULT_CONTENT_TYPE = 'application/x-git-upload-pack-result'.freeze
      RECEIVE_PACK_CONTENT_TYPE = 'application/x-git-receive-pack-request'.freeze
      PUSH_ACCEPT = 'application/x-git-receive-pack-result'.freeze

      MustBeASecondaryNode = Class.new(StandardError)

      class APIResponse
        attr_reader :code, :body

        def initialize(code, body)
          @code = code
          @body = body
        end

        def self.from_http_response(response, primary_repo)
          success = response.is_a?(Net::HTTPSuccess)
          body = response.body.to_s

          if success
            result = Base64.encode64(body)
          else
            message = failed_message(body, primary_repo)
          end

          new(response.code.to_i, status: success, message: message, result: result)
        end

        def self.failed_message(str, primary_repo)
          "Failed to contact primary #{primary_repo}\nError: #{str}"
        end
      end

      class FailedAPIResponse < APIResponse
        def self.from_exception(ex_message, primary_repo, code: 500)
          new(code.to_i,
              status: false,
              message: failed_message(ex_message, primary_repo),
              result: nil)
        end
      end

      def initialize(data)
        @data = data
      end

      def info_refs_upload_pack
        ensure_secondary!

        url = "#{primary_repo}/info/refs?service=git-upload-pack"
        # headers = { 'Content-Type' => UPLOAD_PACK_REQUEST_CONTENT_TYPE }
        headers = {}

        resp = get(url, headers)
        Rails.logger.error("ASH: #info_refs_upload_pack url=[#{url}], headers=[#{headers}] resp.body=[#{resp.body.gsub(/\n/, '')}]")
        resp.body = remove_upload_pack_http_service_fragment_from(resp.body) if resp.is_a?(Net::HTTPSuccess)

        APIResponse.from_http_response(resp, primary_repo)
      rescue => e
        handle_exception(e)
      end

      def upload_pack(encoded_response)
        ensure_secondary!

        url = "#{primary_repo}/git-upload-pack"
        headers = { 'Content-Type' => UPLOAD_PACK_REQUEST_CONTENT_TYPE, 'Accept' => UPLOAD_PACK_RESULT_CONTENT_TYPE }
        decoded_response = Base64.decode64(encoded_response)

        resp = post(url, decoded_response, headers)
        Rails.logger.error("ASH: #upload_pack url=[#{url}], headers=[#{headers}] decoded_response=[#{decoded_response.gsub(/\n/, '')}] resp=[#{resp}]")

        APIResponse.from_http_response(resp, primary_repo)
      rescue => e
        handle_exception(e)
      end

      def receive_pack
        ensure_secondary!

        url = "#{primary_repo}/info/refs?service=git-receive-pack"
        headers = { 'Content-Type' => UPLOAD_PACK_REQUEST_CONTENT_TYPE }

        resp = get(url, headers)
        Rails.logger.error("ASH: #receive_pack url=[#{url}] headers=[#{headers}] resp=[#{resp}]")
        resp.body = remove_receive_pack_http_service_fragment_from(resp.body) if resp.is_a?(Net::HTTPSuccess)

        APIResponse.from_http_response(resp, primary_repo)
      rescue => e
        handle_exception(e)
      end

      def push(encoded_info_refs_response)
        ensure_secondary!

        url = "#{primary_repo}/git-receive-pack"
        headers = { 'Content-Type' => RECEIVE_PACK_CONTENT_TYPE, 'Accept' => PUSH_ACCEPT }
        info_refs_response = Base64.decode64(encoded_info_refs_response)
        resp = post(url, info_refs_response, headers)
        Rails.logger.error("ASH: #push url=[#{url}] headers=[#{headers}] info_refs_response=[#{info_refs_response.gsub(/\n/, '')}] resp=[#{resp}]")

        APIResponse.from_http_response(resp, primary_repo)
      rescue => e
        handle_exception(e)
      end

      private

      attr_reader :data

      def handle_exception(ex)
        case ex
        when MustBeASecondaryNode
          raise(ex)
        else
          FailedAPIResponse.from_exception(ex.message, primary_repo)
        end
      end

      def primary_repo
        @primary_repo ||= data['primary_repo']
      end

      def gl_id
        @gl_id ||= data['gl_id']
      end

      def base_headers
        @base_headers ||= {
          'Geo-GL-Id' => gl_id,
          'Authorization' => Gitlab::Geo::BaseRequest.new(scope: auth_scope).authorization
        }
      end

      def auth_scope
        URI.parse(primary_repo).path.gsub(%r{^\/|\.git$}, '')
      end

      def get(url, headers)
        request(url, Net::HTTP::Get, headers)
      end

      def post(url, body, headers)
        request(url, Net::HTTP::Post, headers, body: body)
      end

      def request(url, klass, headers, body: nil)
        headers = base_headers.merge(headers)
        uri = URI.parse(url)
        req = klass.new(uri, headers)
        req.body = body if body

        http = Net::HTTP.new(uri.hostname, uri.port)
        http.read_timeout = HTTP_READ_TIMEOUT
        http.use_ssl = true if uri.is_a?(URI::HTTPS)

        http.start { http.request(req) }
      end

      def remove_upload_pack_http_service_fragment_from(body)
        # HTTP(S) and SSH responses are very similar, except for the fragment below.
        # As we're performing a git HTTP(S) request here, we'll get a HTTP(s)
        # suitable git response.  However, we're executing in the context of an
        # SSH session so we need to make the response suitable for what git over
        # SSH expects.
        #
        # See Downloading Data > HTTP(S) section at:
        # https://git-scm.com/book/en/v2/Git-Internals-Transfer-Protocols
        # body.gsub(/\A001e# service=git-upload-pack\n0000/, '')
        body.gsub(/\A001e# service=git-upload-pack\n0000/, '')
      end

      def remove_receive_pack_http_service_fragment_from(body)
        # HTTP(S) and SSH responses are very similar, except for the fragment below.
        # As we're performing a git HTTP(S) request here, we'll get a HTTP(s)
        # suitable git response.  However, we're executing in the context of an
        # SSH session so we need to make the response suitable for what git over
        # SSH expects.
        #
        # See Downloading Data > HTTP(S) section at:
        # https://git-scm.com/book/en/v2/Git-Internals-Transfer-Protocols
        body.gsub(/\A001f# service=git-receive-pack\n0000/, '')
      end

      def ensure_secondary!
        raise MustBeASecondaryNode, 'Node is not a secondary or there is no primary Geo node' unless Gitlab::Geo.secondary_with_primary?
      end
    end
  end
end
