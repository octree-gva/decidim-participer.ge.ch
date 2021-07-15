# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
Rails.configuration.log_level = ENV["LOG_LEVEL"].to_sym