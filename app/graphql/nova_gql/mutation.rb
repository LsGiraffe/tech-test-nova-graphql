# frozen_string_literal: true

module NovaGQL
  class Mutation < Base::ProtectedObject
    graphql_name 'Mutation'

    field :approve_document, mutation: Mutations::ApproveDocument
  end
end
