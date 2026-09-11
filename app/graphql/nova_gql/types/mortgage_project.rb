# frozen_string_literal: true

module NovaGQL
  module Types
    class MortgageProject < Base::Object
      field :id, ID, null: false
      field :documents, [Document], null: false
      field :is_blocked, Boolean, null: false

      def is_blocked
        cutoff = 72.hours.ago
        object.documents.any? { |document| document.blocked?(cutoff:) }
      end
    end
  end
end
