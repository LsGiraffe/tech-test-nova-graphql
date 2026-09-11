# frozen_string_literal: true

module NovaGQL
  module Types
    class DateTime < GraphQL::Types::ISO8601DateTime
      graphql_name 'DateTime'
    end
  end
end
