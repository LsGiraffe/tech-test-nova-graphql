# frozen_string_literal: true

module NovaGQL
  module Types
    class DocumentFile < Base::Object
      description 'Simulated stored file backed by the starter file_url. No object storage integration.'
      field :id, ID, null: false
      field :url, String, null: false
    end
  end
end
