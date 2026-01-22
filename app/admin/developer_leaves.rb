ActiveAdmin.register DeveloperLeave do
  menu parent: 'Team', label: 'Developer Leaves'

  permit_params :tonic_developer_id, :start_date, :end_date, :notes, :start_half_day, :end_half_day

  filter :tonic_developer
  filter :start_date
  filter :end_date

  index do
    selectable_column
    id_column
    column :tonic_developer
    column "Start" do |leave|
      text = leave.start_date.strftime('%d %b %Y')
      text += " (PM)" if leave.start_half_day?
      text
    end
    column "End" do |leave|
      text = leave.end_date.strftime('%d %b %Y')
      text += " (AM)" if leave.end_half_day?
      text
    end
    column "Duration" do |leave|
      leave.duration_display
    end
    column :notes
    actions
  end

  form do |f|
    f.inputs "Developer Leave" do
      f.input :tonic_developer
      f.input :start_date, as: :datepicker
      f.input :start_half_day, label: "Start is half day (PM only)", hint: "Check if they're only off in the afternoon"
      f.input :end_date, as: :datepicker
      f.input :end_half_day, label: "End is half day (AM only)", hint: "Check if they're only off in the morning"
      f.input :notes
    end
    f.actions
  end

  show do
    attributes_table do
      row :tonic_developer
      row "Start Date" do |leave|
        text = leave.start_date.strftime('%A, %d %B %Y')
        text += " (PM only)" if leave.start_half_day?
        text
      end
      row "End Date" do |leave|
        text = leave.end_date.strftime('%A, %d %B %Y')
        text += " (AM only)" if leave.end_half_day?
        text
      end
      row "Duration" do |leave|
        leave.duration_display
      end
      row :notes
      row :created_at
      row :updated_at
    end
  end
end

