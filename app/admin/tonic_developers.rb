ActiveAdmin.register TonicDeveloper do
  menu parent: 'Team', label: 'Developers'

  permit_params :name, :project

  filter :name
  filter :project

  index do
    selectable_column
    id_column
    column :name
    column :project
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Developer" do
      f.input :name
      f.input :project
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :project
      row :created_at
      row :updated_at
    end
    
    panel "Upcoming Leaves" do
      table_for resource.developer_leaves.where("end_date >= ?", Date.today).order(:start_date) do
        column :start_date
        column :end_date
        column :notes
        column "Duration" do |leave|
          "#{leave.duration_days} day(s)"
        end
      end
    end
  end
end

