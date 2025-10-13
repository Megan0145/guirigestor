# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.configure do |config|
  # Use the binary from the gem for cross-platform compatibility
  begin
    require 'wkhtmltopdf-binary'
    gem_spec = Gem.loaded_specs['wkhtmltopdf-binary']
    if gem_spec
      gem_path = gem_spec.full_gem_path
      config.exe_path = File.join(gem_path, 'bin', 'wkhtmltopdf')
    else
      # Fallback to trying the gem bin path method
      config.exe_path = `which wkhtmltopdf`.strip
      config.exe_path = '/usr/bin/wkhtmltopdf' if config.exe_path.empty?
    end
  rescue LoadError
    # If gem is not available, try system binary
    config.exe_path = `which wkhtmltopdf`.strip
    config.exe_path = '/usr/bin/wkhtmltopdf' if config.exe_path.empty?
  end
  
  # Enable local file access for assets
  config.enable_local_file_access = true
  
  # Layout file to be used for all PDFs
  config.layout = 'pdf.html'
  
  # Set asset host based on environment
  if Rails.env.production?
    config.asset_host = "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com" if ENV['HEROKU_APP_NAME']
  else
    config.asset_host = "http://localhost:3001"
  end
end
