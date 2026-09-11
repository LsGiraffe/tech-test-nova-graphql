# frozen_string_literal: true

module NovaGQL
  class Query < Base::ProtectedObject
    graphql_name 'Query'

    # Fields are authenticated by default; `enforceable: false` opts out.
    field :ping, String, null: false, enforceable: false, description: 'Health check. Needs no caller.'

    field :client_project, resolver: Queries::ClientProject

    def ping = 'pong'
  end
end
