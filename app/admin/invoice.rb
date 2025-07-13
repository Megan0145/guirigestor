ActiveAdmin.register Invoice do
  permit_params :company_logo, :user_id, :invoice_number, :frequency, :monthly_rate,
                :recipient_company_name, :recipient_vat_number,
                :recipient_address, :recipient_email,
                :sender_company_name, :sender_tax_number,
                :sender_address, :notes, :terms, :bank_details, :tax_rate, :issued_on, :due_on,
                invoice_line_items_attributes: [:id, :description, :rate, :quantity, :total, :_destroy]

  includes :user, :invoice_line_items

  action_item :download_pdf, only: :show do
    link_to "Download PDF", pdf_admin_invoice_path(resource), target: "_blank"
  end
  
  member_action :pdf, method: :get, as: :pdf do
    @invoice = Invoice.find(params[:id])
    render pdf: "invoice_#{@invoice.id}",
           template: 'invoices/pdf',
           layout: 'pdf',
           show_as_html: params[:debug].present?
  end
  member_action :preview, method: :get, as: :preview do
    @invoice = Invoice.find(params[:id])
    render template: 'invoices/pdf', layout: 'pdf'
  end

  action_item :email_invoice, only: :show do
    link_to "Email Invoice", email_admin_invoice_path(invoice), method: :post
  end
  
  member_action :email, method: :post, as: :email do
    invoice = Invoice.find(params[:id])
    InvoiceMailer.send_invoice(invoice).deliver_later
    redirect_to admin_invoice_path(invoice), notice: "Invoice emailed to #{invoice.recipient_email}"
  end

  form do |f|
    f.semantic_errors
    f.inputs "Invoice Details" do
      f.input :company_logo, as: :file, hint: f.object.company_logo.attached? ? image_tag(url_for(f.object.company_logo), height: '50') : content_tag(:span, "No logo yet")
      f.input :invoice_number
      f.input :user
      f.input :frequency, as: :select, collection: ["bi-weekly", "monthly"]
      f.input :monthly_rate
      f.input :tax_rate, input_html: { step: 0.01 }
      f.input :notes
      f.input :terms
      f.input :bank_details
      f.input :issued_on, as: :datepicker
      f.input :due_on, as: :datepicker
    end

    f.inputs "Sender Info" do
      f.input :sender_company_name
      f.input :sender_tax_number
      f.input :sender_address
    end

    f.inputs "Recipient Info" do
      f.input :recipient_company_name
      f.input :recipient_vat_number
      f.input :recipient_address
      f.input :recipient_email
    end

    f.inputs "Line Items" do
      f.has_many :invoice_line_items, allow_destroy: true, new_record: true do |li|
        li.input :description
        li.input :rate
        li.input :quantity
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :user
      row :frequency
      row :monthly_rate
      row :description
      row :issued_on
      row :due_on
      row :sender_company_name
      row :sender_tax_number
      row :sender_address
      row :recipient_company_name
      row :recipient_vat_number
      row :recipient_address
      row :recipient_email
    end

    panel "Line Items" do
      table_for invoice.invoice_line_items do
        column :description
        column :rate
        column :quantity
        column :total
      end
    end
  end
end