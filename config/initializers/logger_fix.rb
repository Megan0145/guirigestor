# Fix for Rails 7.0.3.1 Logger compatibility issue
# This ensures Logger is available before ActiveSupport tries to use it
require 'logger' unless defined?(Logger)
