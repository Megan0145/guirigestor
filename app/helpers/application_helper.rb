module ApplicationHelper

  def base_styles_host
    if request.base_url.include?("localhost")
      "http://docs.dietrails.localhost"
    else
      "https://html-first.com"
    end
  end 

  def available_currencies 
    {
      'EUR' => '€',
      'USD' => '$',
    }
  end

  def months
    {
      1 => 'January',
      2 => 'February',
      3 => 'March',
      4 => 'April',
      5 => 'May',
      6 => 'June',
      7 => 'July',
      8 => 'August',
      9 => 'September',
      10 => 'October',
      11 => 'November',
      12 => 'December',
    }
  end

  def available_years
    [2024, 2025, 2026, 2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035, 2036]
  end

  def status_css_helper(status)
    base = 'border rounded-full '
    
    color = case status
    when 'active', 'ready_for_submission', 'submitted', 'paid'
      'bg-green-100 text-green-800 border-green-800'
    when 'inactive'
      'bg-red-100 text-red-800 border-red-800'
    else
      'bg-gray-100 text-gray-800 border-gray-800'
    end
    "#{base} #{color}"
  end  
end