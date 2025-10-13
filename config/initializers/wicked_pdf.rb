WickedPdf.configure do |config|
  config.exe_path = `which wkhtmltopdf`.strip.presence || '/usr/bin/wkhtmltopdf'
  config.enable_local_file_access = true
  config.layout = 'pdf.html'
  config.asset_host = Rails.env.production? ? "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com" : "http://localhost:3000"
end