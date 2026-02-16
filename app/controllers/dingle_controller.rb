class DingleController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:destroy]
  
  def index
    @expenses = DingleExpense.ordered
    @expenses_by_date = @expenses.group_by(&:expense_date)
    @settlements = DingleExpense.calculate_settlements
    @expense = DingleExpense.new
  end
  
  def create
    @expense = DingleExpense.new(expense_params)
    
    if @expense.save
      flash[:toasts] = [
        { title: "Expense Added", message: "#{@expense.payer} paid €#{@expense.amount}", disappearing: true }
      ]
    else
      flash[:toasts] = [
        { title: "Error", message: @expense.errors.full_messages.join(", ") }
      ]
    end
    
    redirect_to dingle_path
  end
  
  def destroy
    @expense = DingleExpense.find(params[:id])
    @expense.destroy
    
    flash[:toasts] = [
      { title: "Expense Deleted", message: "The expense has been removed", disappearing: true }
    ]
    
    redirect_to dingle_path
  end
  
  private
  
  def expense_params
    permitted = params.require(:dingle_expense).permit(:payer, :description, :amount, :expense_date, split_between: [])
    
    # Convert split_between array to comma-separated string
    if permitted[:split_between].is_a?(Array)
      permitted[:split_between] = permitted[:split_between].reject(&:blank?).join(',')
    end
    
    permitted
  end
end
