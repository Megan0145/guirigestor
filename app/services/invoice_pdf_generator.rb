class InvoicePdfGenerator
  def initialize(invoice)
    @invoice = invoice
  end

  def render
    Prawn::Document.new do |pdf|
      pdf.text "Invoice", size: 30, style: :bold
      pdf.move_down 20

      pdf.text "From:"
      pdf.text @invoice.sender_company_name
      pdf.text @invoice.sender_address
      pdf.text "Tax Number: #{@invoice.sender_tax_number}"
      pdf.move_down 10

      pdf.text "To:"
      pdf.text @invoice.recipient_company_name
      pdf.text @invoice.recipient_address
      pdf.text "VAT: #{@invoice.recipient_vat_number}"
      pdf.move_down 20

      pdf.text "Issued On: #{@invoice.issued_on}"
      pdf.text "Due On: #{@invoice.due_on}"
      pdf.move_down 20

      pdf.text "Description: #{@invoice.description}"
      pdf.move_down 20

      pdf.table line_items_table, header: true, row_colors: ["F0F0F0", "FFFFFF"]
      pdf.move_down 20

      pdf.text "Total: €#{@invoice.total_amount}", size: 16, style: :bold
    end.render
  end

  private

  def line_items_table
    [["Description", "Rate", "Quantity", "Total"]] +
      @invoice.invoice_line_items.map do |item|
        [item.description, "€#{item.rate}", item.quantity, "€#{item.total}"]
      end
  end
end