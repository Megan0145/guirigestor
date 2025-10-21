ActiveAdmin.register_page "Bulk Receipt Upload" do
  menu parent: 'Accounting', label: "Bulk Upload Receipts"

  content do
    render partial: 'admin/bulk_receipt_upload/upload_form'
  end
end

