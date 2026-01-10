ActiveAdmin.register BrainDump do
  menu parent: "Personal Development", priority: 2, label: "Brain Dumps"
  
  permit_params :content, :date, tag_ids: []
  
  filter :date
  filter :tags, as: :select, collection: -> { BrainDumpTag.ordered }
  filter :created_at
  
  index do
    selectable_column
    id_column
    column :date
    column :content do |dump|
      truncate(dump.content, length: 100)
    end
    column :tags do |dump|
      dump.tags.map(&:name).join(", ")
    end
    column :created_at
    actions
  end
  
  show do
    attributes_table do
      row :id
      row :date
      row :tags do |dump|
        dump.tags.map(&:name).join(", ")
      end
      row :content do |dump|
        simple_format(dump.content)
      end
      row :created_at
      row :updated_at
    end
  end
  
  form do |f|
    f.inputs do
      f.input :date, as: :datepicker
      f.input :content, as: :text, input_html: { rows: 10 }
      f.input :tags, as: :check_boxes, collection: BrainDumpTag.ordered
    end
    f.actions
  end
end

