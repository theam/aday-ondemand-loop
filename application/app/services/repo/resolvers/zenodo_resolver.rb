module Repo
  module Resolvers
    class ZenodoResolver < Repo::BaseResolver
      include LoggingCommon

      def self.build
        new
      end

      def priority
        20_000
      end

      def resolve(context)
        return unless context.object_url
        domain = context.parsed_input&.domain
        return unless domain
        if domain.include?('zenodo.org')
          context.type = ConnectorType::ZENODO
          context.repo_db.set(domain, type: ConnectorType::ZENODO)
        end
      end
    end
  end
end
