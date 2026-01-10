ActiveAdmin.register BrainDumpTag do
  menu parent: "Personal Development", priority: 3, label: "Brain Dump Tags"
  
  permit_params :name
  
  filter :name
  filter :created_at
  
  index do
    selectable_column
    id_column
    column :name
    column "Dumps" do |tag|
      tag.brain_dumps.count
    end
    column :created_at
    actions
  end
  
  show do
    attributes_table do
      row :id
      row :name
      row "Dumps" do |tag|
        tag.brain_dumps.count
      end
      row :created_at
      row :updated_at
    end
    
    panel "Brain Dumps with this tag" do
      table_for resource.brain_dumps.ordered.limit(20) do
        column :date
        column :content do |dump|
          truncate(dump.content, length: 150)
        end
        column "" do |dump|
          link_to "View", admin_brain_dump_path(dump)
        end
      end
    end
  end
  
  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end
end

