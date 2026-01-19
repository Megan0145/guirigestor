class FiscalQuartersController < ApplicationController
  before_action :set_fiscal_quarter, only: [:show, :verify_passcode, :download_invoice, :download_autonomo_payment, :download_outgoing_receipt, :view_invoice, :view_autonomo_payment, :view_outgoing_receipt, :download_all_invoices, :download_selected_receipts]
  skip_before_action :verify_authenticity_token, only: [:verify_passcode]

  def show
    @invoices = @fiscal_quarter.invoices.includes(:invoice_line_items).order(invoice_number: :asc)
    @autonomo_payments = @fiscal_quarter.autonomo_payments
    @outgoing_receipts = @fiscal_quarter.outgoing_receipts.order(:month)
  end

  def verify_passcode
    respond_to do |format|
      format.json do
        if params[:passcode] == @fiscal_quarter.passcode
          render json: { success: true }
        else
          render json: { success: false, error: t('fiscal_quarter.passcode.invalid') }
        end
      end
    end
  end

  def download_invoice
    @invoice = @fiscal_quarter.invoices.find(params[:invoice_id])
    
    respond_to do |format|
      format.pdf do
        render pdf: "invoice_#{@invoice.invoice_number}",
               template: 'invoices/pdf',
               layout: 'pdf',
               formats: [:html],
               disposition: 'attachment'
      end
    end
  end

  def download_autonomo_payment
    @payment = @fiscal_quarter.autonomo_payments.find(params[:payment_id])
    
    if @payment.payment_file.attached?
      redirect_to rails_blob_path(@payment.payment_file, disposition: "attachment")
    else
      redirect_to fiscal_quarter_path(@fiscal_quarter.identifier), alert: 'No file attached to this payment.'
    end
  end

  def download_outgoing_receipt
    @receipt = @fiscal_quarter.outgoing_receipts.find(params[:receipt_id])
    
    if @receipt.receipt_file.attached?
      redirect_to rails_blob_path(@receipt.receipt_file, disposition: "attachment")
    else
      redirect_to fiscal_quarter_path(@fiscal_quarter.identifier), alert: 'No file attached to this receipt.'
    end
  end

  def view_invoice
    @invoice = @fiscal_quarter.invoices.find(params[:invoice_id])
    
    respond_to do |format|
      format.pdf do
        render pdf: "invoice_#{@invoice.invoice_number}",
               template: 'invoices/pdf',
               layout: 'pdf',
               formats: [:html],
               disposition: 'inline'
      end
    end
  end

  def view_autonomo_payment
    @payment = @fiscal_quarter.autonomo_payments.find(params[:payment_id])
    
    if @payment.payment_file.attached?
      redirect_to rails_blob_path(@payment.payment_file, disposition: "inline")
    else
      redirect_to fiscal_quarter_path(@fiscal_quarter.identifier), alert: 'No file attached to this payment.'
    end
  end

  def view_outgoing_receipt
    @receipt = @fiscal_quarter.outgoing_receipts.find(params[:receipt_id])
    
    if @receipt.receipt_file.attached?
      redirect_to rails_blob_path(@receipt.receipt_file, disposition: "inline")
    else
      redirect_to fiscal_quarter_path(@fiscal_quarter.identifier), alert: 'No file attached to this receipt.'
    end
  end

  def download_all_invoices
    # For now, redirect to a simple message until ZIP functionality is working
    redirect_to fiscal_quarter_path(@fiscal_quarter.identifier), 
                notice: "ZIP download functionality is being implemented. Please download invoices individually for now."
  end

  def download_selected_receipts
    receipt_ids = params[:receipt_ids] || []
    receipts = @fiscal_quarter.outgoing_receipts.where(id: receipt_ids)
    
    if receipts.empty?
      redirect_to fiscal_quarter_path(@fiscal_quarter.identifier), alert: 'No receipts selected.'
      return
    end
    
    # Create ZIP in memory
    zip_data = Zip::OutputStream.write_buffer do |zip|
      receipts.each do |receipt|
        if receipt.receipt_file.attached?
          zip.put_next_entry("#{receipt.service || 'receipt'}_#{receipt.id}.#{receipt.receipt_file.filename.extension}")
          zip.write receipt.receipt_file.download
        end
      end
    end
    
    zip_data.rewind
    send_data zip_data.read, 
              filename: "#{@fiscal_quarter.name.parameterize}-recibos-#{@fiscal_quarter.user&.name&.parameterize}.zip",
              type: 'application/zip',
              disposition: 'attachment'
  end

  private
  def set_fiscal_quarter
    @fiscal_quarter = FiscalQuarter.find_by!(identifier: params[:identifier])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Fiscal quarter not found.'
  end
end
