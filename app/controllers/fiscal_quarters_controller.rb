class FiscalQuartersController < ApplicationController
  before_action :set_fiscal_quarter, only: [:show, :verify_passcode, :download_invoice, :download_autonomo_payment, :download_outgoing_receipt, :view_invoice, :view_autonomo_payment, :view_outgoing_receipt]
  before_action :set_locale
  skip_before_action :verify_authenticity_token, only: [:verify_passcode]

  def show
    @invoices = @fiscal_quarter.invoices.includes(:invoice_line_items)
    @autonomo_payments = @fiscal_quarter.autonomo_payments
    @outgoing_receipts = @fiscal_quarter.outgoing_receipts
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

  private

  def set_locale
    if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
      session[:locale] = params[:locale]
    elsif session[:locale]
      I18n.locale = session[:locale]
    end
  end

  def set_fiscal_quarter
    @fiscal_quarter = FiscalQuarter.find_by!(identifier: params[:identifier])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Fiscal quarter not found.'
  end
end
