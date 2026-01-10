class MiscController < ApplicationController
  before_action :set_current_month, only: [:developer_calendar, :add_developer_leave, :delete_developer_leave]
  before_action :authenticate_megan!, only: [:brain_dump, :brain_dump_history]
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
  
  # Brain Dump
  def brain_dump
    @today = Date.today
    @tags = BrainDumpTag.ordered
    @saved = false
    @reviewing = false
    @cleaned_content = nil
    @suggested_tags = []
    @raw_content = nil
    
    if request.post?
      # Step 1: Process with AI (show review modal)
      if params[:action_type] == "process"
        @raw_content = params[:content]
        existing_tag_names = @tags.pluck(:name)
        
        # Process with AI to clean up and get suggested tags
        processor = BrainDumpProcessor.new
        result = processor.process(@raw_content, existing_tag_names)
        
        if result[:success]
          @cleaned_content = result[:cleaned_text]
          @suggested_tags = result[:suggested_tags] || []
          @ai_success = true
        else
          # If AI fails, use raw input as-is
          @cleaned_content = @raw_content
          @suggested_tags = []
          @ai_success = false
          Rails.logger.warn("[BrainDump] AI processing failed: #{result[:error]}")
        end
        
        @reviewing = true
        
      # Step 2: Actually save (after review)
      elsif params[:action_type] == "save"
        raw_input = params[:raw_content]
        cleaned_content = params[:cleaned_content]
        
        @brain_dump = BrainDump.new(
          content: cleaned_content,      # The enriched/cleaned version
          raw_content: raw_input,         # Preserve the original
          date: @today
        )
        
        # Handle confirmed tags
        if params[:confirmed_tags].present?
          tag_names = params[:confirmed_tags].is_a?(Array) ? params[:confirmed_tags] : params[:confirmed_tags].split(",")
          tag_names.each do |name|
            name = name.strip.downcase
            next if name.blank?
            tag = BrainDumpTag.find_or_create_by(name: name)
            @brain_dump.tags << tag unless @brain_dump.tags.include?(tag)
          end
        end
        
        if @brain_dump.save
          @saved = true
          flash.now[:toasts] = [
            { title: "Saved", message: "Your thoughts are encrypted & safe", disappearing: true }
          ]
        else
          flash.now[:toasts] = [
            { title: "Error", message: @brain_dump.errors.full_messages.join(", ") }
          ]
        end
      end
    end
  end
  
  def brain_dump_history
    @tags = BrainDumpTag.with_dumps.ordered
    @search_query = params[:q]
    @show_raw = params[:show_raw] == "true"
    
    # Support multiple selected tags
    @selected_tag_ids = []
    if params[:tags].present?
      @selected_tag_ids = Array(params[:tags]).map(&:to_i).reject(&:zero?)
    elsif params[:tag].present?
      # Backwards compatibility with single tag
      @selected_tag_ids = [params[:tag].to_i]
    end
    @selected_tags = BrainDumpTag.where(id: @selected_tag_ids)
    
    @dumps = BrainDump.ordered.includes(:tags)
    
    # Filter by selected tags (OR logic - show if has ANY of the selected tags)
    if @selected_tag_ids.any?
      dump_ids = BrainDump.joins(:tags).where(brain_dump_tags: { id: @selected_tag_ids }).distinct.pluck(:id)
      @dumps = @dumps.where(id: dump_ids)
    end
    
    @dumps = @dumps.to_a # Load into memory for search since content is encrypted
    
    # Filter by search query - searches both raw and enriched content
    if @search_query.present?
      @dumps = @dumps.select { |d| d.matches_search?(@search_query) }
    end
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
  
  def authenticate_megan!
    unless admin_user_signed_in? && current_admin_user.email == "meganennis.dev@gmail.com" || admin_user_signed_in? && current_admin_user.email == "megan@guirigestor.com"
      redirect_to root_path, alert: "Access denied"
    end
  end
end
