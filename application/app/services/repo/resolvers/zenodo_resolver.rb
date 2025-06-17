module Repo
  module Resolvers
    class ZenodoResolver < Repo::BaseResolver
      include LoggingCommon

      def self.build
        new
      end

      def priority
        9000
      end

      def resolve(context)
        return unless context.object_url
        uri = URI.parse(context.object_url) rescue nil
        return unless uri
        return unless uri.host&.include?('zenodo')
        context.type = ConnectorType::ZENODO
        context.repo_db.set(uri.host, type: ConnectorType::ZENODO)
      end
    end
  end
end
