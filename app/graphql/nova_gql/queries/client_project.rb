# frozen_string_literal: true

module NovaGQL
  module Queries
    class ClientProject < Base::Query
      type Types::MortgageProject, null: false

      def resolve
        unless viewer.client?
          raise GraphQL::ExecutionError.new('This query is reserved for clients.', extensions: { code: 'FORBIDDEN' })
        end

        project
      end
    end
  end
end
