ActiveAdmin.register OutgoingReceipt do
  permit_params :user_id, :status, :uploaded_on, :notes, :payment_file, :fiscal_quarter_id
  
  filter :user
  filter :status
  filter :uploaded_on
  filter :notes
  filter :fiscal_quarter
  filter :created_at
  filter :updated_at

  batch_action :assign_fiscal_quarter do |ids|
    current_quarter = ENV['CURRENT_QUARTER']
    fq = FiscalQuarter.find_by(name: current_quarter)
    OutgoingReceipt.where(id: ids).update_all(fiscal_quarter_id: fq.id)
    redirect_to collection_path, notice: "Assigned #{ids.size} outgoing receipts to #{current_quarter}."
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
    column :uploaded_on
    column :fiscal_quarter
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Outgoing Receipt" do
      f.input :user
      f.input :fiscal_quarter, as: :select, collection: FiscalQuarter.all.map { |fq| ["#{fq.name} - #{fq.user.name} - #{fq.start_date} to #{fq.end_date}", fq.id] }
      f.input :status, as: :select, collection: OutgoingReceipt.statuses.keys
      f.input :uploaded_on
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
      row :uploaded_on
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