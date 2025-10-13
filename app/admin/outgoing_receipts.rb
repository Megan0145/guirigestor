ActiveAdmin.register OutgoingReceipt do
  permit_params :user_id, :status, :uploaded_on, :notes, :payment_file

  
  filter :user
  filter :status
  filter :uploaded_on
  filter :notes

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
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Outgoing Receipt" do
      f.input :user
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