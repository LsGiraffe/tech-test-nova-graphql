# frozen_string_literal: true

module NovaGQL
  module Types
    module Payload
      class ApproveDocumentPayload < Base::Object
        field :document, Types::Document, null: true
      end
    end
  end
end
