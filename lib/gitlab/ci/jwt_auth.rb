module Gitlab
  module Ci
    class JwtAuth
      include Gitlab::Utils::StrongMemoize

      def self.jwt_for_build(build)
        ttl = build.metadata_timeout || 60
        payload = self.new(build).payload(ttl: ttl)

        JWT.encode(
          payload,
          OpenSSL::PKey::RSA.new(Rails.application.secrets.openid_connect_signing_key),
          "RS256"
        )
      end

      def initialize(build)
        @build = build
      end

      def payload(ttl:)
        now = Time.now.to_i

        {
          # Standard JWT attributes
          iss: Settings.gitlab.host,
          iat: now,
          exp: now + ttl,
          sub: build.project_id.to_s,

          # Custom attributes
          nid: namespace_id,
          pid: build.project_id.to_s,
          uid: build.user_id.to_s,
          jid: build.id.to_s,
          ref: build.ref,
          ref_type: ref_type,
          ref_protection: protected_ref_wildcards,
          env: build.environment
        }
      end

      private

      attr_reader :build

      def project
        build.project
      end

      def namespace_id
        prefix = project.namespace.type.presence || 'user'

        "#{prefix.downcase}:#{project.namespace.id}"
      end

      def ref_type
        strong_memoize(:ref_type) do
          if build.branch?
            'branch'
          elsif build.tag?
            'tag'
          elsif build.merge_request?
            'mr'
          end
        end
      end

      def protected_ref_wildcards
        matching = []

        if project.default_branch_protected? && ref_type == 'branch' && build.ref == project.default_branch
          matching << build.project.default_branch
        end

        protected_refs = case ref_type
                         when 'branch'
                           project.protected_branches
                         when 'tag'
                           project.protected_tags
                         # when 'mr' ???
                         end

        return matching unless protected_refs

        matching + protected_refs.matching(build.ref).map(&:name)
      end
    end
  end
end
