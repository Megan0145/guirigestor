ActiveAdmin.register_page "ProcessReceipts" do
  menu parent: 'Accounting', label: "Process Receipts"

  content do
    render partial: 'admin/process_receipts/interface'
  end
end

