ActiveAdmin.register DeveloperLeave do
  menu parent: 'Team', label: 'Developer Leaves'

  permit_params :tonic_developer_id, :start_date, :end_date, :notes

  filter :tonic_developer
  filter :start_date
  filter :end_date

  index do
    selectable_column
    id_column
    column :tonic_developer
    column :start_date
    column :end_date
    column "Duration" do |leave|
      "#{leave.duration_days} day(s)"
    end
    column :notes
    actions
  end

  form do |f|
    f.inputs "Developer Leave" do
      f.input :tonic_developer
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :notes
    end
    f.actions
  end

  show do
    attributes_table do
      row :tonic_developer
      row :start_date
      row :end_date
      row "Duration" do |leave|
        "#{leave.duration_days} day(s)"
      end
      row :notes
      row :created_at
      row :updated_at
    end
  end
end

