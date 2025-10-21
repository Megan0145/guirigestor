module Admin
  class BulkUploadReceiptsController < ApplicationController
    before_action :authenticate_admin_user!

    def upload
      file = params[:receipt_file]
      
      if file.blank?
        render json: { success: false, error: 'No file provided' }, status: :bad_request
        return
      end

      # Get current admin user's associated user or first user
      user = current_admin_user.email == 'megan@girihesdord.com' ? User.first : User.first
      
      receipt = OutgoingReceipt.new(
        user: user,
        part_of_bulk_upload: true,
        assigned: false,
        uploaded_on: DateTime.now
      )
      
      receipt.receipt_file.attach(file)
      
      if receipt.save(validate: false)
        # Process through AI in background
        begin
          processor = ReceiptAiProcessor.new(receipt.receipt_file)
          ai_suggestions = processor.extract_details
          
          # Store AI suggestions as JSON in a session or cache
          # For now, update the receipt with AI suggestions
          receipt.update_columns(
            service_id: ai_suggestions[:service_id],
            amount: ai_suggestions[:amount],
            currency: ai_suggestions[:currency],
            month: ai_suggestions[:month],
            year: ai_suggestions[:year],
            status: ai_suggestions[:status],
            notes: "[AI: #{ai_suggestions[:confidence]}] #{ai_suggestions[:notes]}"
          )
          
          Rails.logger.info "AI processed receipt ##{receipt.id} with #{ai_suggestions[:confidence]} confidence"
          
          render json: { 
            success: true, 
            id: receipt.id,
            ai_processed: true,
            confidence: ai_suggestions[:confidence]
          }
        rescue StandardError => e
          Rails.logger.error "AI processing failed for receipt ##{receipt.id}: #{e.message}"
          render json: { 
            success: true, 
            id: receipt.id,
            ai_processed: false,
            error: e.message
          }
        end
      else
        render json: { success: false, error: receipt.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
  end
end

