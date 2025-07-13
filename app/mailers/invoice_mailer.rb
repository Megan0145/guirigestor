class InvoiceMailer < ApplicationMailer
  def send_invoice(invoice)
    @invoice = invoice
    attachments["invoice_#{invoice.id}.pdf"] = InvoicePdfGenerator.new(@invoice).render
    mail(to: @invoice.recipient_email, subject: "Your Invoice from #{@invoice.sender_company_name}")
  end
end
