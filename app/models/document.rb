# frozen_string_literal: true

class Document < ApplicationRecord
  belongs_to :mortgage_project
  belongs_to :mortgagor, optional: true
  def blocked?(cutoff: 72.hours.ago)
    waiting_since = case status
                    when 'pending' then requested_at
                    when 'uploaded' then submitted_at
                    when 'rejected' then rejected_at
                    end
    waiting_since.present? && waiting_since < cutoff
  end
end
