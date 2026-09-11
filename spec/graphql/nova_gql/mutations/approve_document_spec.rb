# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NovaGQL::Mutations::ApproveDocument, type: :mutation do
  include ActiveSupport::Testing::TimeHelpers

  let(:project) { Fabricate(:mortgage_project) }
  let(:document) do
    Fabricate(:document, mortgage_project: project, status: 'uploaded',
              requested_at: 5.days.ago, submitted_at: 4.days.ago,
              file_url: 'https://files.example/document.pdf')
  end
  let(:viewer) { Viewer.new(role: :advisor, project_id: project.id, mortgagor_id: nil) }
  let(:query) do
    <<~GRAPHQL
      mutation ApproveDocument($input: ApproveDocumentInput!) {
        approveDocument(input: $input) {
          document { id status approvedAt }
        }
      }
    GRAPHQL
  end

  def execute(context: { viewer: })
    NovaGQL::Schema.execute(query, variables: { input: { documentId: document.id } }, context:).to_h
  end

  it 'persists the approval, returns the document and ends its pending wait' do
    freeze_time do
      submitted_at = document.submitted_at
      result = execute
      expect(result['errors']).to be_nil
      expect(result.dig('data', 'approveDocument', 'document')).to eq(
        'id' => document.id.to_s, 'status' => 'APPROVED', 'approvedAt' => Time.current.iso8601
      )
      document.reload
      expect(document.status).to eq('validated')
      expect(document.approved_at).to eq(Time.current)
      expect(document.submitted_at).to eq(submitted_at)
      expect(document.blocked?).to be(false)
    end
  end

  it 'rejects other states without changing the document' do
    %w[pending rejected validated].each do |status|
      document.update!(status:)
      before = document.reload.attributes
      expect(execute.dig('errors', 0, 'extensions', 'code')).to eq('INVALID_STATE')
      expect(document.reload.attributes).to eq(before)
    end
  end

  it 'rejects clients without approving the document' do
    client = Viewer.new(role: :client, project_id: project.id, mortgagor_id: nil)
    expect(execute(context: { viewer: client }).dig('errors', 0, 'extensions', 'code')).to eq('FORBIDDEN')
    expect(document.reload.status).to eq('uploaded')
    expect(document.approved_at).to be_nil
  end

  it 'does not approve a document outside the expert’s project' do
    other_project = Fabricate(:mortgage_project)
    expert = Viewer.new(role: :advisor, project_id: other_project.id, mortgagor_id: nil)
    expect(execute(context: { viewer: expert }).dig('errors', 0, 'extensions', 'code')).to eq('NOT_FOUND')
    expect(document.reload.status).to eq('uploaded')
    expect(document.approved_at).to be_nil
  end
end
