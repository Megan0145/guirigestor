ActiveAdmin.register Service do
  menu parent: 'Accounting'

  permit_params :user_id, :name, :description, :amount, :currency, :active, :variable_amount

  filter :user
  filter :name
  filter :description
  filter :amount
  filter :currency
  filter :active
  filter :variable_amount

  index do
    selectable_column
    id_column
    column :user
    column :name
    column :description
    column :amount do |service|
      number_to_currency(service.amount, unit: available_currencies[service.currency])
    end
    column :currency
    column :active
    column :variable_amount
    actions
  end

  form do |f|
    f.inputs "Service" do
      f.input :user
      f.input :name
      f.input :description
      f.input :amount
      f.input :currency
      f.input :active
      f.input :variable_amount
    end
    f.actions
  end

  show do
    attributes_table do
      row :user
      row :name
      row :description
      row :amount
      row :currency
      row :active
      row :variable_amount
    end
  end
end