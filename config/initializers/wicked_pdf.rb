WickedPdf.configure do |config|
  # Detect which wkhtmltopdf gem is available
  if Gem.loaded_specs['wkhtmltopdf-heroku']
    # Heroku-specific binary path
    gem_path = Gem.loaded_specs['wkhtmltopdf-heroku'].full_gem_path
    config.exe_path = File.join(gem_path, 'bin', 'wkhtmltopdf-heroku')
  elsif Gem.loaded_specs['wkhtmltopdf-binary']
    # Local development / test
    gem_path = Gem.loaded_specs['wkhtmltopdf-binary'].full_gem_path
    config.exe_path = File.join(gem_path, 'bin', 'wkhtmltopdf')
  else
    # Fallback to system binary (if any)
    config.exe_path = `which wkhtmltopdf`.strip.presence || '/usr/bin/wkhtmltopdf'
  end

  # Enable local file access
  config.enable_local_file_access = true

  # Default layout for PDFs
  config.layout = 'pdf.html'

  # Asset host configuration
  if Rails.env.production?
    config.asset_host = "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com" if ENV['HEROKU_APP_NAME'].present?
  else
    config.asset_host = "http://localhost:3001"
  end
end