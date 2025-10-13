ActiveAdmin.register AutonomoPayment do
  permit_params :user_id, :status, :uploaded_on, :notes, :payment_file, :fiscal_quarter_id

  filter :user
  filter :status
  filter :uploaded_on
  filter :notes
  filter :fiscal_quarter

  batch_action :assign_fiscal_quarter do |ids|
    current_quarter = ENV['CURRENT_QUARTER']
    fq = FiscalQuarter.find_by(name: current_quarter)
    AutonomoPayment.where(id: ids).update_all(fiscal_quarter_id: fq.id)
    redirect_to collection_path, notice: "Assigned #{ids.size} autonomo payments to #{current_quarter}."
  end
  
  index do
    selectable_column
    id_column
    column :user
    column :status do |autonomo_payment|
      case autonomo_payment.status
      when 'paid'
        div class: "status-tag", data: { status: :yes } do
          autonomo_payment.status.humanize
        end
      when 'pending'
        div class: "status-tag", data: { status: :maybe } do
          autonomo_payment.status.humanize
        end
      when 'rejected'
        div class: "status-tag", data: { status: :no } do
          autonomo_payment.status.humanize
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
    f.inputs "Autonomo Payment" do
      f.input :user
      f.input :fiscal_quarter, as: :select, collection: FiscalQuarter.all.map { |fq| ["#{fq.name} - #{fq.user.name} - #{fq.start_date} to #{fq.end_date}", fq.id] }
      f.input :status, as: :select, collection: AutonomoPayment.statuses.keys
      f.input :uploaded_on
      f.input :notes, as: :text, input_html: { rows: 3 }
    end
    f.inputs "Payment File" do
      f.input :payment_file, as: :file
    end
    f.actions
  end

  show do
    attributes_table do
      row :user
      row :fiscal_quarter
      row :status do |autonomo_payment|
        case autonomo_payment.status
        when 'paid'
          div class: "status-tag", data: { status: :yes } do
            autonomo_payment.status.humanize
          end
        when 'pending'
          div class: "status-tag", data: { status: :maybe } do
            autonomo_payment.status.humanize
          end
        when 'rejected'
          div class: "status-tag", data: { status: :no } do
            autonomo_payment.status.humanize
          end
        end
      end
      row :uploaded_on
      row :notes
      row :payment_file do |autonomo_payment|
        if autonomo_payment.payment_file.attached?
          link_to autonomo_payment.payment_file.filename, url_for(autonomo_payment.payment_file)
        end
      end
      row :created_at
      row :updated_at
    end
  end
end