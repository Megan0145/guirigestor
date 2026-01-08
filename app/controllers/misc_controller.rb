class MiscController < ApplicationController
  before_action :set_current_month, only: [:developer_calendar, :add_developer_leave, :delete_developer_leave]
  
  def thank_you_jack
    render :thank_you_jack
  end
  
  # Developer Calendar
  def developer_calendar
    @developers = TonicDeveloper.all.order(:name)
    @projects = TonicDeveloper.pluck(:project).uniq.compact.sort
    
    # Filter by selected projects (params[:projects] comes as array from checkboxes)
    if params[:projects].present?
      @selected_projects = Array(params[:projects])
    else
      @selected_projects = @projects
    end
    
    filtered_developer_ids = TonicDeveloper.where(project: @selected_projects).pluck(:id)
    @leaves = DeveloperLeave.for_month(@current_date)
                            .where(tonic_developer_id: filtered_developer_ids)
                            .includes(:tonic_developer)
  end
  
  def add_developer_leave
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
  
  def delete_developer_leave
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
