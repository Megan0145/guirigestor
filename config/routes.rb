Rails.application.routes.draw do
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  # Dingle Trip Expense Tracker
  get '/dingle',
    to: 'dingle#index',
    as: 'dingle'
  
  post '/dingle/expenses',
    to: 'dingle#create',
    as: 'dingle_create_expense'
  
  delete '/dingle/expenses/:id',
    to: 'dingle#destroy',
    as: 'dingle_delete_expense'
  
  # Landing page
  get '/landing', 
    to: 'landing#index', 
    as: 'landing'
  
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

  get '/truelayer/connect',
    to: 'truelayer#connect',
    as: 'truelayer_connect'

  get '/truelayer/callback',
    to: 'truelayer#callback',
    as: 'truelayer_callback'

  # Cursor invoice automation
  namespace :api do
    post '/invoices/cursor',
      to: 'cursor_invoices#create',
      as: 'cursor_invoice_upload'
    
    post '/invoices/cursor/download',
      to: 'cursor_invoices#download_all',
      as: 'cursor_invoice_download'
    
    get '/service_accounts/:service_name',
      to: 'service_accounts#show',
      as: 'service_account'
    
    namespace :work_tooling do
      post '/platform-sync/notion-task-to-asana-task',
        to: 'platform_sync#sync_notion_task_to_asana_task',
        as: 'sync_notion_task_to_asana_task'
    end
  end

  
  # Personal
  # Better than yesterday
  match '/bty',
    to: 'misc#bty_new',
    as: 'bty',
    via: [:get, :post]
  
  get '/bty/metrics',
    to: 'misc#bty_metrics',
    as: 'bty_metrics'
  
  get '/bty/calendar',
    to: 'misc#bty_metrics',
    as: 'bty_calendar'
  
  # Brain dump
  match '/dump',
    to: 'misc#brain_dump',
    as: 'brain_dump',
    via: [:get, :post]
  
  get '/dump/history',
    to: 'misc#brain_dump_history',
    as: 'brain_dump_history'
  
  # Digests
  get '/dump/digests',
    to: 'misc#digests',
    as: 'digests'
  
  get '/dump/digests/new',
    to: 'misc#new_digest',
    as: 'new_digest'
  
  post '/dump/digests',
    to: 'misc#create_digest',
    as: 'create_digest'
  
  get '/dump/digests/:id',
    to: 'misc#show_digest',
    as: 'digest'
  
  post '/dump/digests/:id/messages',
    to: 'misc#digest_message',
    as: 'digest_message'
  
  get '/dump/digests/:id/stream',
    to: 'misc#digest_stream',
    as: 'digest_stream'


  # Misc
  get '/thank-you-jack',
    to: 'misc#thank_you_jack',
    as: 'thank_you_jack'
  
  # Developer Calendar
  get '/developer-calendar',
    to: 'misc#developer_calendar',
    as: 'developer_calendar'
  
  match '/developer-calendar/add-leave',
    to: 'misc#add_developer_leave',
    as: 'add_developer_leave',
    via: [:get, :post]
  
  match '/developer-calendar/leave/:id',
    to: 'misc#delete_developer_leave',
    as: 'delete_developer_leave',
    via: [:post, :delete]
end