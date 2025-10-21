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
        render json: { success: true, id: receipt.id }
      else
        render json: { success: false, error: receipt.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
  end
end

