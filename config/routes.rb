Rails.application.routes.draw do
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  # Bulk upload receipts endpoint
  namespace :admin do
    post 'bulk_upload_receipts/upload', to: 'bulk_upload_receipts#upload'
    
    # Process receipts endpoints
    get 'process_receipts/:id/edit', to: 'process_receipts#edit'
    post 'process_receipts/:id/update', to: 'process_receipts#update'
    get 'process_receipts/:id/preview', to: 'process_receipts#preview'
    post 'process_receipts/:id/mark_assigned', to: 'process_receipts#mark_assigned'
  end

  root to: "app#index"

  get "/search", to: "h1rails/demos#search"

  draw :h1_demo_routes
  draw :h1_expo_routes 
  draw :livecode_routes

  devise_for :users, controllers: {
    sessions:       'users/sessions',
    registrations:  'users/registrations',
    passwords:      'users/passwords',
  }

  get '/thank-you-jack',
    to: 'misc#thank_you_jack',
    as: 'thank_you_jack'

  # Fiscal Quarter public view
  get '/:identifier', 
    to: 'fiscal_quarters#show', 
    as: 'fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  # Fiscal Quarter passcode verification
  post '/:identifier/verify-passcode', 
    to: 'fiscal_quarters#verify_passcode', 
    as: 'verify_passcode_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  # Fiscal Quarter download actions
  get '/:identifier/invoices/download-all', 
    to: 'fiscal_quarters#download_all_invoices', 
    as: 'download_all_invoices_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  get '/:identifier/invoices/:invoice_id/download', 
    to: 'fiscal_quarters#download_invoice', 
    as: 'download_invoice_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  get '/:identifier/autonomo-payments/:payment_id/download', 
    to: 'fiscal_quarters#download_autonomo_payment', 
    as: 'download_autonomo_payment_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  post '/:identifier/outgoing-receipts/download-selected', 
    to: 'fiscal_quarters#download_selected_receipts', 
    as: 'download_selected_receipts_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  get '/:identifier/outgoing-receipts/:receipt_id/download', 
    to: 'fiscal_quarters#download_outgoing_receipt', 
    as: 'download_outgoing_receipt_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  # Fiscal Quarter view actions
  get '/:identifier/invoices/:invoice_id/view', 
    to: 'fiscal_quarters#view_invoice', 
    as: 'view_invoice_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  get '/:identifier/autonomo-payments/:payment_id/view', 
    to: 'fiscal_quarters#view_autonomo_payment', 
    as: 'view_autonomo_payment_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  get '/:identifier/outgoing-receipts/:receipt_id/view', 
    to: 'fiscal_quarters#view_outgoing_receipt', 
    as: 'view_outgoing_receipt_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

end