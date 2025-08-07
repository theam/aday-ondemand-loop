# frozen_string_literal: true

require 'resolv'

module Repo
  module Resolvers
    class DomainResolver < Repo::BaseResolver
      include LoggingCommon

      def self.build
        new
      end

      # Highest priority so it runs before other resolvers
      def priority
        100_000
      end

      def resolve(context)
        return unless context.parsed_input.nil?

        parsed = RepoUrl.parse("https://#{context.input}")
        host = parsed&.domain

        return unless resolvable_domain?(host)

        context.object_url = parsed.to_s
      end

      private

      def resolvable_domain?(host)
        return false if host.blank?
        Resolv.getaddress(host)
        true
      rescue Resolv::ResolvError
        false
      end
    end
  end
end
