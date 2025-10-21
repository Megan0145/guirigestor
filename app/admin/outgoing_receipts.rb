ActiveAdmin.register OutgoingReceipt do
  menu parent: 'Accounting'

  permit_params :user_id, :status, :uploaded_on, :notes, :fiscal_quarter_id, :service, :amount, :receipt_file, :currency, :service_id, :month, :year, :assigned
  
  # Scopes for assigned/unassigned
  scope :all, default: true
  scope :assigned
  scope :unassigned
  
  filter :user
  filter :status
  filter :assigned
  filter :service_id, as: :select, collection: Service.all.map { |service| [service.name, service.id] }
  filter :amount
  filter :uploaded_on
  filter :notes
  filter :fiscal_quarter
  filter :month
  filter :year
  filter :created_at
  filter :updated_at

  batch_action :assign_fiscal_quarter do |ids|
    current_quarter = ENV['CURRENT_QUARTER']
    fq = FiscalQuarter.find_by(name: current_quarter)
    OutgoingReceipt.where(id: ids).update_all(fiscal_quarter_id: fq.id)
    redirect_to collection_path, notice: "Assigned #{ids.size} outgoing receipts to #{current_quarter}."
  end

  batch_action :mark_as_assigned do |ids|
    OutgoingReceipt.where(id: ids).update_all(assigned: true)
    redirect_to collection_path, notice: "Marked #{ids.size} outgoing receipts as assigned."
  end

  batch_action :mark_as_unassigned do |ids|
    OutgoingReceipt.where(id: ids).update_all(assigned: false)
    redirect_to collection_path, notice: "Marked #{ids.size} outgoing receipts as unassigned."
  end

  index do
    selectable_column
    id_column
    column :user
    column :status do |outgoing_receipt|
      case outgoing_receipt.status
      when 'paid'
        div class: "status-tag", data: { status: :yes } do
          outgoing_receipt.status.humanize
        end
      when 'pending'
        div class: "status-tag", data: { status: :maybe } do
          outgoing_receipt.status.humanize
        end
      when 'rejected'
        div class: "status-tag", data: { status: :no } do
          outgoing_receipt.status.humanize
        end
      end
    end
    column :service
    column :amount do |outgoing_receipt|
      outgoing_receipt.display_amount
    end
    column :date do |outgoing_receipt|
      outgoing_receipt.display_month_and_year
    end
    column :fiscal_quarter
    actions
  end

  form do |f|
    f.inputs "Outgoing Receipt" do
      f.input :user
      f.input :fiscal_quarter, as: :select, collection: FiscalQuarter.all.map { |fq| ["#{fq.name} - #{fq.user.name} - #{fq.start_date} to #{fq.end_date}", fq.id] }
      f.input :status, as: :select, collection: OutgoingReceipt.statuses.keys
      f.input :service
      f.input :amount
      f.input :currency, as: :select, collection: available_currencies.keys
      f.input :uploaded_on
      f.input :month, as: :select, collection: months.map { |key, value| [value, key] }
      f.input :year, as: :select, collection: available_years
      f.input :notes, as: :text, input_html: { rows: 3 }
    end
    f.inputs "Receipt File" do
      f.input :receipt_file, as: :file
    end
    f.actions
  end

  show do
    attributes_table do
      row :user
      row :fiscal_quarter
      row :status do |outgoing_receipt|
        case outgoing_receipt.status
        when 'paid'
          div class: "status-tag", data: { status: :yes } do
            outgoing_receipt.status.humanize
          end
        when 'pending'
          div class: "status-tag", data: { status: :maybe } do
            outgoing_receipt.status.humanize
          end
        when 'rejected'
          div class: "status-tag", data: { status: :no } do
            outgoing_receipt.status.humanize
          end
        end
      end
      row :service
      row :amount do |outgoing_receipt|
        number_to_currency(outgoing_receipt.amount, unit: available_currencies[outgoing_receipt.currency])
      end
      row :uploaded_on
      row :month
      row :year
      row :notes
      row :receipt_file do |outgoing_receipt|
        if outgoing_receipt.receipt_file.attached?
          link_to outgoing_receipt.receipt_file.filename, url_for(outgoing_receipt.receipt_file)
        end
      end
      row :created_at
      row :updated_at
    end
  end
end