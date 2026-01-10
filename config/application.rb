require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TonicRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.action_mailer.delivery_method = :postmark

    config.action_mailer.postmark_settings = {
      api_token: ENV.fetch('POSTMARK_API_PRODUCTION_KEY')
    }

    # Internationalization configuration
    config.i18n.available_locales = [:en, :es]
    config.i18n.default_locale = :en
    config.active_job.queue_adapter = :delayed_job
    
    # Active Record Encryption (for Brain Dump feature)
    # Keys must be set via environment variables - never commit raw keys
    if ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'].present?
      config.active_record.encryption.primary_key = ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY']
      config.active_record.encryption.deterministic_key = ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY']
      config.active_record.encryption.key_derivation_salt = ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT']
    end
  end
end
