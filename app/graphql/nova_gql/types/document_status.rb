# frozen_string_literal: true

module NovaGQL
  module Types
    class DocumentStatus < GraphQL::Schema::Enum
      value 'REQUESTED', value: 'pending'
      value 'SUBMITTED', value: 'uploaded'
      value 'REJECTED', value: 'rejected'
      value 'APPROVED', value: 'validated'
    end
  end
end
