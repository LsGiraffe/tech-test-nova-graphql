# frozen_string_literal: true

module NovaGQL
  module Mutations
    class ApproveDocument < Base::Mutation
      description 'Approves a submitted document in the expert’s authorized project.'

      argument :input, Types::Input::ApproveDocumentInput, required: true
      type Types::Payload::ApproveDocumentPayload, null: false

      def resolve(input:)
        unless viewer.advisor?
          raise GraphQL::ExecutionError.new('Only experts can approve documents.', extensions: { code: 'FORBIDDEN' })
        end

        # The starter simulates expert assignment through viewer.project_id.
        document = project.documents.find(input.document_id)
        document.with_lock do
          unless document.status == 'uploaded'
            raise GraphQL::ExecutionError.new('Only submitted documents can be approved.', extensions: { code: 'INVALID_STATE' })
          end

          document.update!(status: 'validated', approved_at: Time.current)
        end

        { document: }
      end
    end
  end
end
