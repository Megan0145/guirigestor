ActiveAdmin.register FiscalQuarter do
  menu parent: 'Accounting'

  permit_params :name, :start_date, :end_date, :status, :notes, :identifier, :passcode, :year, :quarter, :user_id

  filter :name
  filter :year
  filter :quarter
  filter :status
  filter :notes
  filter :identifier
  filter :passcode
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :user
    column :name
    column :start_date
    column :end_date
    column :status do |fiscal_quarter|
      case fiscal_quarter.status
      when 'active'
        div class: "status-tag", data: { status: :yes } do
          fiscal_quarter.status.humanize
        end
      when 'inactive'
        div class: "status-tag", data: { status: :no } do
          fiscal_quarter.status.humanize
        end
      end
    end
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :user, as: :select
      f.input :name
      f.input :year
      f.input :quarter, as: :select, collection: ["Q1", "Q2", "Q3", "Q4"]
      f.input :start_date
      f.input :end_date
      f.input :status, as: :select, collection: FiscalQuarter.statuses.keys
      f.input :notes, as: :text, input_html: { rows: 3 }
      f.input :identifier
      f.input :passcode

      f.actions
    end
  end

  show do
    attributes_table do
      row :user
      row :name
      row :year
      row :quarter
      row :start_date
      row :end_date
      row :status do |fiscal_quarter|
        case fiscal_quarter.status
        when 'active'
          div class: "status-tag", data: { status: :yes } do
            fiscal_quarter.status.humanize
          end
        when 'inactive'
          div class: "status-tag", data: { status: :no } do
            fiscal_quarter.status.humanize
          end
        end
      end
      row :notes
      row :identifier
      row :passcode do |fiscal_quarter|
        # hide on initial render, expose onclick
        if fiscal_quarter.passcode.present?
          div class: "passcode", onclick: "revealPasscode(this)" do
            fiscal_quarter.passcode
          end
        end
      end
      row :created_at
      row :updated_at
    end
    panel "Autonomo Payments" do
      table_for fiscal_quarter.autonomo_payments do
        column :user
        column :status
        column :uploaded_on
        column :notes
        column :payment_file
        column :actions do |autonomo_payment|
          div do
            link_to "View", admin_autonomo_payment_path(autonomo_payment), target: "_blank", class: "member_link"
          end
          div do
            link_to "Edit", edit_admin_autonomo_payment_path(autonomo_payment), class: "member_link"
          end
          div do 
            link_to "Delete", admin_autonomo_payment_path(autonomo_payment), method: :delete, class: "member_link"
          end
        end
      end
    end
    panel "Outgoing Receipts" do
      table_for fiscal_quarter.outgoing_receipts do
        column :user
        column :status
        column :uploaded_on
        column :notes
        column :receipt_file
        column :actions do |outgoing_receipt|
          div do
            link_to "View", admin_outgoing_receipt_path(outgoing_receipt), target: "_blank", class: "member_link"
          end
          div do
            link_to "Edit", edit_admin_outgoing_receipt_path(outgoing_receipt), class: "member_link"
          end
          div do 
            link_to "Delete", admin_outgoing_receipt_path(outgoing_receipt), method: :delete, class: "member_link"
          end
        end
      end
    end
    panel "Invoices" do
      table_for fiscal_quarter.invoices do
        column :user
        column :invoice_number
        column :issued_on
        column :due_on
        column :total_amount do |invoice|
          number_to_currency(invoice.total_amount, unit: Invoice::CURRENCIES[invoice.currency])
        end
        column :actions do |invoice|
          div do
            link_to "View", admin_invoice_path(invoice), target: "_blank", class: "member_link"
          end
          div do
            link_to "Edit", edit_admin_invoice_path(invoice), class: "member_link"
          end
          div do 
            link_to "Delete", admin_invoice_path(invoice), method: :delete, class: "member_link"
          end
        end
      end
    end
  end
end
