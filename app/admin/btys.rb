ActiveAdmin.register Bty do
  menu parent: "Personal Development", label: "Better Than Yesterday"
  permit_params :date, :value

  index do
    column :date
    column :value
    actions
  end

  form do |f|
    f.inputs "Bty" do
      f.input :date
      f.input :value
    end
    f.actions
  end

  show do
    attributes_table do
      row :date
      row :value
    end
  end
end