ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require "bootsnap"

env = ENV["RAILS_ENV"] || "development"

Bootsnap.setup(
  cache_dir: File.expand_path(File.join("..", "tmp", "cache"), __dir__),
  development_mode: env == "development",
  load_path_cache: true,
  autoload_paths_cache: true,
  compile_cache_iseq: ["1", "true", "enabled"].include?(ENV.fetch("SIMPLECOV", "false")),
  compile_cache_yaml: true
)
 