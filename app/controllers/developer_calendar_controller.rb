class DeveloperCalendarController < ApplicationController
  before_action :set_current_month
  
  def index
    @developers = TonicDeveloper.all.order(:name)
    @leaves = DeveloperLeave.for_month(@current_date).includes(:tonic_developer)
  end
  
  def add_leave
    @developer_leave = DeveloperLeave.new(leave_params)
    
    if @developer_leave.save
      flash[:toasts] = [
        { title: "Leave Saved", message: "Developer leave has been recorded" }
      ]
      redirect_to developer_calendar_path(
        month: @developer_leave.start_date.month, 
        year: @developer_leave.start_date.year
      )
    else
      flash[:toasts] = [
        { title: "Error", message: @developer_leave.errors.full_messages.join(", ") }
      ]
      redirect_to developer_calendar_path(
        month: params[:date].present? ? Date.parse(params[:date]).month : Date.today.month,
        year: params[:date].present? ? Date.parse(params[:date]).year : Date.today.year
      )
    end
  end
  
  def delete_leave
    @leave = DeveloperLeave.find(params[:id])
    @leave.destroy
    
    flash[:toasts] = [
      { title: "Leave Deleted", message: "The leave entry has been removed" }
    ]
    
    redirect_to developer_calendar_path(
      month: params[:month] || Date.today.month,
      year: params[:year] || Date.today.year
    )
  end
  
  private
  
  def set_current_month
    @current_date = if params[:month].present? && params[:year].present?
      Date.new(params[:year].to_i, params[:month].to_i, 1)
    else
      Date.today.beginning_of_month
    end
  end
  
  def leave_params
    params.require(:developer_leave).permit(:tonic_developer_id, :start_date, :end_date, :notes)
  end
end
