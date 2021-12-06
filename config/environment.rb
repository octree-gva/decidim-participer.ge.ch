# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
Rails.configuration.log_level = ENV.fetch("LOG_LEVEL", "debug").to_sym