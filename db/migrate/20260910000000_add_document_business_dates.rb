# frozen_string_literal: true

class AddDocumentBusinessDates < ActiveRecord::Migration[8.1]
  def up
    add_column :documents, :instructions, :text
    add_column :documents, :requested_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :documents, :submitted_at, :datetime
    add_column :documents, :rejected_at, :datetime
    add_column :documents, :approved_at, :datetime

    # Legacy example data has no business history. These dates are approximations
    # for existing rows only. Future writes must record the actual events.
    execute <<~SQL
      UPDATE documents SET
        requested_at = created_at,
        submitted_at = CASE WHEN file_url IS NOT NULL THEN created_at END,
        rejected_at = CASE WHEN status = 'rejected' THEN updated_at END,
        approved_at = CASE WHEN status = 'validated' THEN updated_at END
    SQL
    execute <<~SQL
      UPDATE documents SET instructions = 'For ' || mortgagors.first_name || ' ' || mortgagors.last_name
      FROM mortgagors WHERE documents.mortgagor_id = mortgagors.id
    SQL
  end

  def down
    remove_column :documents, :instructions
    remove_column :documents, :requested_at
    remove_column :documents, :submitted_at
    remove_column :documents, :rejected_at
    remove_column :documents, :approved_at
  end
end
