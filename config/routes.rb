Rails.application.routes.draw do
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

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
  get '/:identifier/invoices/:invoice_id/download', 
    to: 'fiscal_quarters#download_invoice', 
    as: 'download_invoice_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  get '/:identifier/autonomo-payments/:payment_id/download', 
    to: 'fiscal_quarters#download_autonomo_payment', 
    as: 'download_autonomo_payment_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

  get '/:identifier/outgoing-receipts/:receipt_id/download', 
    to: 'fiscal_quarters#download_outgoing_receipt', 
    as: 'download_outgoing_receipt_fiscal_quarter',
    constraints: { identifier: /[a-z0-9]{5}/ }

end