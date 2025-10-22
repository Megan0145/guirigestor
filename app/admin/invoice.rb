ActiveAdmin.register Invoice do
  menu parent: 'Accounting'
  
  permit_params :company_logo, :user_id, :invoice_number, :currency, :frequency, :rate,
                :recipient_company_name, :recipient_vat_number,
                :recipient_address, :recipient_email,
                :sender_company_name, :sender_tax_number,
                :sender_address, :notes, :terms, :bank_details, :tax_rate, :issued_on, :due_on, :fiscal_quarter_id,
                invoice_line_items_attributes: [:id, :description, :rate, :quantity, :total, :_destroy]

  includes :user, :invoice_line_items

  filter :user
  filter :invoice_number
  filter :frequency
  filter :rate
  filter :tax_rate
  filter :issued_on
  filter :due_on
  filter :fiscal_quarter
  filter :created_at
  filter :updated_at

  action_item :download_pdf, only: :show do
    link_to "Download PDF", pdf_admin_invoice_path(resource), target: "_blank", class: "action-item-button"
  end

  action_item :submit_airtable_form, only: :show do
    airtable_form_url = ENV['AIRTABLE_FORM_URL']
    params = {
      "prefill_Invoice Number/Identifier" => resource.invoice_number,
      "prefill_Amount" => resource.total_amount,
      "prefill_Currency" => 1,
    }

    prefill_query = params.compact.to_query

    link_to "Render Airtable Form", "#{airtable_form_url}?#{prefill_query}", target: "_blank", class: "action-item-button"
  end

  action_item :preview_invoice, only: :show do
    link_to "Preview Invoice", preview_admin_invoice_path(resource), target: "_blank", class: "action-item-button"
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

  member_action :clone_invoice, method: :post, as: :clone do
    invoice = Invoice.find(params[:id])
    cloned_invoice = invoice.dup
    cloned_invoice.invoice_number = invoice&.invoice_number&.to_i + 1
    cloned_invoice.issued_on = Date.today
    cloned_invoice.due_on = Date.today
    cloned_invoice.save!
    redirect_to admin_invoice_path(cloned_invoice), notice: "Invoice cloned successfully."
  end

  member_action :email, method: :post, as: :email do
    invoice = Invoice.find(params[:id])
    InvoiceMailer.send_invoice(invoice).deliver_later
    redirect_to admin_invoice_path(invoice), notice: "Invoice emailed to #{invoice.recipient_email}"
  end

  batch_action :clone_invoices do |selection|
    invoices = Invoice.where(id: selection)
    invoices.each do |invoice|
      cloned_invoice = invoice.dup
      cloned_invoice.fiscal_quarter_id = invoice&.fiscal_quarter_id
      cloned_invoice.invoice_number = invoice&.invoice_number&.to_i + 1
      cloned_invoice.issued_on = Date.today
      cloned_invoice.due_on = Date.today
      cloned_invoice.save!
  
      # Re-attach company logo if present
      if invoice.company_logo.attached?
        cloned_invoice.company_logo.attach(invoice.company_logo.blob)
      end
  
      invoice.invoice_line_items.each do |item|
        cloned_item = item.dup
        cloned_item.invoice_id = cloned_invoice.id
        cloned_item.save!
      end
    end
    redirect_to admin_invoices_path, notice: "Cloned #{invoices.count} invoices successfully."
  end

  batch_action :assign_fiscal_quarter do |ids|
    current_quarter = ENV['CURRENT_QUARTER']
    fq = FiscalQuarter.find_by(name: current_quarter)
    Invoice.where(id: ids).update_all(fiscal_quarter_id: fq.id)
    redirect_to collection_path, notice: "Assigned #{ids.size} invoices to #{current_quarter}."
  end

  index do
    selectable_column
    id_column
    column :sender_company_name
    column :recipient_company_name
    column :invoice_number
    column :amount do |invoice|
      number_to_currency(invoice.rate, unit: available_currencies[invoice.currency])
    end 
    column :frequency do |invoice|
      invoice.frequency.humanize
    end
    column :issued_on
    column :due_on
    column :fiscal_quarter
    column :created_at
    actions defaults: true do |invoice|
      item "Preview", preview_admin_invoice_path(invoice), target: "_blank", class: "member_link"
      item "Download PDF", pdf_admin_invoice_path(invoice), target: "_blank", class: "member_link"
      item "Email Invoice", email_admin_invoice_path(invoice), method: :post, class: "member_link"
    end

  end

  form do |f|
    f.semantic_errors
    f.input :fiscal_quarter, as: :select, collection: FiscalQuarter.all.map { |fq| ["#{fq.name} - #{fq.user.name} - #{fq.start_date} to #{fq.end_date}", fq.id] }
    f.inputs "Invoice Details" do
      f.input :company_logo, as: :file, hint: f.object.company_logo.attached? ? image_tag(url_for(f.object.company_logo), height: '50') : content_tag(:span, "No logo yet")
      f.input :invoice_number
      f.input :currency, as: :select, collection: available_currencies.keys, include_blank: false
      f.input :user
      f.input :frequency, as: :select, collection: ["bi-weekly", "monthly"]
      f.input :rate
      f.input :tax_rate, input_html: { step: 0.01 }
      f.input :notes
      f.input :terms
      f.input :bank_details
      f.input :issued_on
      f.input :due_on
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
      row :id
      row :invoice_number
      row :user
      row :fiscal_quarter
      row :frequency do |invoice|
        invoice.frequency.humanize
      end
      row :amount do |invoice|
        number_to_currency(invoice.rate, unit: available_currencies[invoice.currency])
      end
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