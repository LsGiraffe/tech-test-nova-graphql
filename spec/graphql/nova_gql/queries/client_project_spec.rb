# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NovaGQL::Queries::ClientProject, type: :query do
  include ActiveSupport::Testing::TimeHelpers

  let(:project) { Fabricate(:mortgage_project) }
  let(:viewer) { Viewer.new(role: :client, project_id: project.id, mortgagor_id: nil) }
  let(:query) do
    <<~GRAPHQL
      { clientProject {
        id isBlocked documents {
          id documentType instructions status rejectionReason
          requestedAt submittedAt rejectedAt approvedAt file { id url }
        }
      } }
    GRAPHQL
  end

  def execute(query_text = query, context: { viewer: })
    NovaGQL::Schema.execute(query_text, context:).to_h
  end

  it 'returns only the associated project, including missing and rejected documents' do
    missing = Fabricate(:document, mortgage_project: project, instructions: 'For Alex', requested_at: 1.hour.ago)
    rejected = Fabricate(:document, mortgage_project: project, status: 'rejected',
                        requested_at: 5.days.ago, submitted_at: 2.days.ago, rejected_at: 1.day.ago,
                        file_url: 'https://files.example/rejected.pdf', rejection_reason: 'Unreadable')
    Fabricate(:document)

    result = execute
    expect(result['errors']).to be_nil
    data = result.fetch('data').fetch('clientProject')
    expect(data['id']).to eq(project.id.to_s)
    expect(data['isBlocked']).to be(false)
    expect(data['documents'].map { |doc| doc['id'] }).to contain_exactly(missing.id.to_s, rejected.id.to_s)
    expect(data['documents'].find { |doc| doc['id'] == missing.id.to_s })
      .to include('status' => 'REQUESTED', 'documentType' => 'Identity card', 'instructions' => 'For Alex', 'file' => nil)
    expect(data['documents'].find { |doc| doc['id'] == rejected.id.to_s })
      .to include('status' => 'REJECTED', 'rejectionReason' => 'Unreadable',
                  'file' => { 'id' => "document-#{rejected.id}-file", 'url' => rejected.file_url })
  end

  it 'uses the current action date and a strict 72-hour threshold to determine blocking' do
    freeze_time do
      document = Fabricate(:document, mortgage_project: project, requested_at: 72.hours.ago)
      expect(execute.dig('data', 'clientProject', 'isBlocked')).to be(false)
      document.update!(requested_at: 73.hours.ago)
      expect(execute.dig('data', 'clientProject', 'isBlocked')).to be(true)
      document.update!(status: 'uploaded', submitted_at: 1.hour.ago)
      expect(execute.dig('data', 'clientProject', 'isBlocked')).to be(false)
      document.update!(submitted_at: 73.hours.ago)
      expect(execute.dig('data', 'clientProject', 'isBlocked')).to be(true)
      document.update!(status: 'rejected', rejected_at: 1.hour.ago)
      expect(execute.dig('data', 'clientProject', 'isBlocked')).to be(false)
      document.update!(rejected_at: 73.hours.ago)
      expect(execute.dig('data', 'clientProject', 'isBlocked')).to be(true)
      document.update!(status: 'validated', approved_at: Time.current)
      expect(execute.dig('data', 'clientProject', 'isBlocked')).to be(false)
      expect(execute.dig('data', 'clientProject', 'documents', 0, 'status')).to eq('APPROVED')
    end
  end

  it 'rejects experts' do
    viewer = Viewer.new(role: :advisor, project_id: project.id, mortgagor_id: nil)
    expect(execute(context: { viewer: }).dig('errors', 0, 'extensions', 'code')).to eq('FORBIDDEN')
  end

  it 'reports a missing project' do
    project.destroy!
    expect(execute.dig('errors', 0, 'extensions', 'code')).to eq('NOT_FOUND')
  end
end
