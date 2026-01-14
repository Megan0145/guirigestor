ActiveAdmin.register BrainDigest, as: "Digest" do
  menu parent: "Personal Development", priority: 4, label: "Digests"

  permit_params :digest_type, :schedule_period, :title, :content

  filter :digest_type, as: :select, collection: [['Custom', 'custom'], ['Scheduled', 'scheduled']]
  filter :schedule_period, as: :select, collection: [['Weekly', 'weekly'], ['Monthly', 'monthly'], ['Yearly', 'yearly']]
  filter :created_at

  index do
    selectable_column
    id_column
    column :title do |digest|
      digest.display_title
    end
    column :digest_type
    column :schedule_period
    column "Brain Dumps" do |digest|
      digest.brain_dumps.count
    end
    column "Messages" do |digest|
      digest.digest_messages.count
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :title do |digest|
        digest.display_title
      end
      row :digest_type
      row :schedule_period
      row "Brain Dumps" do |digest|
        digest.brain_dumps.count
      end
      row :content do |digest|
        simple_format(digest.content) if digest.content.present?
      end
      row :created_at
      row :updated_at
    end

    panel "Conversation" do
      table_for resource.digest_messages.ordered do
        column :role
        column :content do |msg|
          truncate(msg.content, length: 200)
        end
        column :created_at
      end
    end

    panel "Associated Brain Dumps" do
      table_for resource.brain_dumps.ordered do
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
      f.input :title
      f.input :digest_type, as: :select, collection: [['Custom', 'custom'], ['Scheduled', 'scheduled']]
      f.input :schedule_period, as: :select, collection: [['Weekly', 'weekly'], ['Monthly', 'monthly'], ['Yearly', 'yearly']]
      f.input :content, as: :text, input_html: { rows: 10 }
    end
    f.actions
  end
end

