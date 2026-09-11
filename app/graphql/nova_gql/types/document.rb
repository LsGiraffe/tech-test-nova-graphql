# frozen_string_literal: true

module NovaGQL
  module Types
    class Document < Base::Object
      field :id, ID, null: false
      field :document_type, String, null: false
      field :instructions, String, null: true
      field :status, DocumentStatus, null: false
      field :file, DocumentFile, null: true
      field :rejection_reason, String, null: true
      field :internal_note, String, null: true
      field :requested_at, DateTime, null: false
      field :submitted_at, DateTime, null: true
      field :rejected_at, DateTime, null: true
      field :approved_at, DateTime, null: true

      def document_type = object.kind.humanize

      def file
        return if object.file_url.blank?

        # A local stand-in for an upload reference, not a real storage identifier.
        { id: "document-#{object.id}-file", url: object.file_url }
      end

      def rejection_reason
        object.rejection_reason if object.status == 'rejected'
      end

      def internal_note
        unless viewer&.advisor?
          raise GraphQL::ExecutionError.new('Internal notes are reserved for experts.', extensions: { code: 'FORBIDDEN' })
        end

        object.internal_note
      end
    end
  end
end
