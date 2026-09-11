# frozen_string_literal: true

# Two projects covering the awkward cases: a couple where one borrower is
# self-employed, and a solo borrower with a rejected document.
#
# Reloadable on purpose: it wipes first, so you can run `rake db:seed` again
# whenever you've made a mess of the data.

Document.delete_all
Mortgagor.delete_all
MortgageProject.delete_all

couple = MortgageProject.create!(
  reference: 'PRE-1042',
  advisor_name: 'Camille Rousseau',
  contact_phone: '+33600000001'
)
alex = couple.mortgagors.create!(first_name: 'Alex', last_name: 'Marchand', employment_status: 'employee', main: true)
sam = couple.mortgagors.create!(first_name: 'Sam', last_name: 'Marchand', employment_status: 'self_employed')

couple.documents.create!(kind: 'identity_card', status: 'validated', mortgagor: alex, file_url: 'https://files.example/1.pdf')
couple.documents.create!(kind: 'identity_card', status: 'pending', mortgagor: sam)
couple.documents.create!(kind: 'payslip', status: 'uploaded', mortgagor: alex, file_url: 'https://files.example/2.pdf')
couple.documents.create!(kind: 'payslip', status: 'uploaded', mortgagor: alex, file_url: 'https://files.example/3.pdf')
couple.documents.create!(kind: 'balance_sheet', status: 'pending', mortgagor: sam)
couple.documents.create!(kind: 'sale_agreement', status: 'pending')

solo = MortgageProject.create!(
  reference: 'PRE-1043',
  advisor_name: 'Camille Rousseau',
  contact_phone: '+33600000002'
)
robin = solo.mortgagors.create!(first_name: 'Robin', last_name: 'Nguyen', employment_status: 'employee', main: true)

solo.documents.create!(
  kind: 'identity_card',
  status: 'rejected',
  mortgagor: robin,
  file_url: 'https://files.example/4.pdf',
  rejection_reason: 'expired',
  internal_note: 'Relancé par téléphone le 3, sans réponse.'
)
solo.documents.create!(kind: 'tax_notice', status: 'pending', mortgagor: robin)

# Explicit example dates and recipient guidance for the client query.
Document.includes(:mortgagor).find_each do |document|
  document.update!(
    requested_at: 5.days.ago,
    submitted_at: document.file_url.present? ? 4.days.ago : nil,
    rejected_at: document.status == 'rejected' ? 1.day.ago : nil,
    approved_at: document.status == 'validated' ? 3.days.ago : nil,
    instructions: document.mortgagor ? "For #{document.mortgagor.first_name} #{document.mortgagor.last_name}" : 'For the whole project'
  )
end

puts "Seeded #{MortgageProject.count} projects, #{Document.count} documents."
