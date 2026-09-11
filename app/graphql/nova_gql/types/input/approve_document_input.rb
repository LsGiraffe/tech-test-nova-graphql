# frozen_string_literal: true

module NovaGQL
  module Types
    module Input
      class ApproveDocumentInput < GraphQL::Schema::InputObject
        argument :document_id, ID, required: true
      end
    end
  end
end
