class FiscalQuartersController < ApplicationController
  before_action :set_fiscal_quarter, only: [:show, :verify_passcode]

  def show
    @invoices = @fiscal_quarter.invoices.includes(:invoice_line_items)
    @autonomo_payments = @fiscal_quarter.autonomo_payments
    @outgoing_receipts = @fiscal_quarter.outgoing_receipts
  end

  def verify_passcode
    if params[:passcode] == @fiscal_quarter.passcode
      render json: { success: true }
    else
      render json: { success: false, error: 'Invalid passcode' }
    end
  end

  private

  def set_fiscal_quarter
    @fiscal_quarter = FiscalQuarter.find_by!(identifier: params[:identifier])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Fiscal quarter not found.'
  end
end
