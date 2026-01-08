class MiscController < ApplicationController
  before_action :set_current_month, only: [:developer_calendar, :add_developer_leave, :delete_developer_leave]
  # before_action :authenticate_user_or_admin!, only: [:bty_new, :bty_metrics]
  
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


  # Personal Development
  # Better than yesterday
  def bty_new
    @today = Date.today
    @already_answered = Bty.exists?(date: @today)
    @todays_answer = Bty.find_by(date: @today) if @already_answered
    
    if request.post?
      # Check if already answered today
      existing = Bty.find_by(date: @today)
      if existing
        existing.update(value: params[:value] == 'true')
        flash[:toasts] = [
          { title: "Updated!", message: "Your answer has been updated", disappearing: true }
        ]
      else
        @bty = Bty.new(value: params[:value] == 'true', date: @today)
        if @bty.save
          flash[:toasts] = [
            { title: "Recorded!", message: params[:value] == 'true' ? "Keep pushing! 💪" : "Tomorrow is a new day 🌅", disappearing: true }
          ]
        end
      end
      redirect_to bty_metrics_path
    end
  end

  def bty_metrics
    @current_year = params[:year]&.to_i || Date.today.year
    @btys = Bty.for_year(@current_year).ordered
    @all_btys = Bty.ordered
    
    # Calculate stats
    @total_days = @btys.count
    @yes_days = @btys.where(value: true).count
    @no_days = @btys.where(value: false).count
    @streak = calculate_current_streak
    
    # Calculate cumulative score (running total)
    @cumulative_score = calculate_cumulative_score(@all_btys)
    
    # Calculate monthly growth comparisons
    @monthly_growth = calculate_monthly_growth
  end
  
  private
  
  def calculate_current_streak
    streak = 0
    date = Date.today
    
    loop do
      bty = Bty.find_by(date: date)
      break if bty.nil? || !bty.yes?
      streak += 1
      date -= 1.day
    end
    
    streak
  end
  
  def calculate_cumulative_score(btys)
    btys.sum { |b| b.yes? ? 1 : -1 }
  end
  
  def calculate_monthly_growth
    today = Date.today
    
    # Current month
    current_month_start = today.beginning_of_month
    current_month_btys = Bty.where(date: current_month_start..today)
    current_month_score = current_month_btys.sum { |b| b.yes? ? 1 : -1 }
    current_month_days = current_month_btys.count
    
    # Previous month
    prev_month_start = (today - 1.month).beginning_of_month
    prev_month_end = (today - 1.month).end_of_month
    prev_month_btys = Bty.where(date: prev_month_start..prev_month_end)
    prev_month_score = prev_month_btys.sum { |b| b.yes? ? 1 : -1 }
    prev_month_days = prev_month_btys.count
    
    # Calculate cumulative scores up to end of each month
    all_btys_to_current = Bty.where("date <= ?", today).ordered
    all_btys_to_prev_month = Bty.where("date <= ?", prev_month_end).ordered
    
    cumulative_current = calculate_cumulative_score(all_btys_to_current)
    cumulative_prev = calculate_cumulative_score(all_btys_to_prev_month)
    
    # Month over month growth (cumulative comparison)
    monthly_delta = cumulative_current - cumulative_prev
    
    {
      current_month: {
        name: today.strftime('%B'),
        score: current_month_score,
        days: current_month_days,
        cumulative: cumulative_current
      },
      previous_month: {
        name: (today - 1.month).strftime('%B'),
        score: prev_month_score,
        days: prev_month_days,
        cumulative: cumulative_prev
      },
      delta: monthly_delta,
      trend: monthly_delta > 0 ? :up : (monthly_delta < 0 ? :down : :same)
    }
  end
  
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
  
  # Uncomment and adjust as needed for BTY authentication
  # def authenticate_user_or_admin!
  #   unless user_signed_in? || admin_user_signed_in?
  #     redirect_to root_path, alert: "You must be logged in to access this page"
  #   end
  # end
end
