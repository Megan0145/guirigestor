module Admin
  class ProcessReceiptsController < ApplicationController
    before_action :authenticate_admin_user!
    before_action :set_receipt, only: [:edit, :update, :preview, :mark_assigned]

    def edit
      render partial: 'admin/process_receipts/edit_form', layout: false
    end

    def update
      @receipt.part_of_bulk_upload = false # Enable validations
      
      if @receipt.update(receipt_params)
        Rails.logger.info "Receipt ##{@receipt.id} updated successfully by #{current_admin_user.email}"
        render partial: 'admin/process_receipts/edit_form', layout: false
      else
        Rails.logger.error "Failed to update Receipt ##{@receipt.id}: #{@receipt.errors.full_messages.join(', ')}"
        @errors = @receipt.errors.full_messages
        render partial: 'admin/process_receipts/edit_form', layout: false, status: :unprocessable_entity
      end
    end

    def preview
      if @receipt.receipt_file.attached?
        render plain: rails_blob_path(@receipt.receipt_file, disposition: "inline")
      else
        render plain: '', status: :not_found
      end
    end

    def mark_assigned
      @receipt.part_of_bulk_upload = false # Enable validations
      
      # First, try to update with any pending form data
      if params[:outgoing_receipt].present?
        unless @receipt.update(receipt_params)
          Rails.logger.error "Failed to save Receipt ##{@receipt.id} before marking assigned: #{@receipt.errors.full_messages.join(', ')}"
          render json: { success: false, errors: @receipt.errors.full_messages }
          return
        end
      end
      
      # Check if receipt has required fields
      if @receipt.service.blank? || @receipt.fiscal_quarter.blank? || @receipt.status.blank?
        errors = []
        errors << "Service can't be blank" if @receipt.service.blank?
        errors << "Fiscal quarter can't be blank" if @receipt.fiscal_quarter.blank?
        errors << "Status can't be blank" if @receipt.status.blank?
        
        Rails.logger.error "Cannot mark Receipt ##{@receipt.id} as assigned - missing required fields: #{errors.join(', ')}"
        render json: { success: false, errors: errors }
        return
      end
      
      # Mark as assigned
      if @receipt.update(assigned: true)
        Rails.logger.info "Receipt ##{@receipt.id} marked as assigned by #{current_admin_user.email}"
        render json: { success: true }
      else
        Rails.logger.error "Failed to mark Receipt ##{@receipt.id} as assigned: #{@receipt.errors.full_messages.join(', ')}"
        render json: { success: false, errors: @receipt.errors.full_messages }
      end
    end

    private

    def set_receipt
      @receipt = OutgoingReceipt.find(params[:id])
    end

    def receipt_params
      params.require(:outgoing_receipt).permit(
        :fiscal_quarter_id, :service_id, :month, :year, 
        :amount, :currency, :status, :notes
      )
    end
  end
end

