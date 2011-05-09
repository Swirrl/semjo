require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
require "action_dispatch/railtie"

Bundler.require(:default, Rails.env) if defined?(Bundler)

module Semjo
  class Application < Rails::Application
    
    # JavaScript files you want as :defaults (application.js is always included).
    config.action_view.javascript_expansions[:defaults] = %w(jquery rails application)
    
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
    config.autoload_paths << File.join(config.root, "lib")
    
    config.time_zone = 'London'
  end
end