AcmProto::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # ActionMailer Config
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  # change to true to allow email to be sent during development
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"

  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "example.com",
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: ENV["GMAIL_USERNAME"],
    password: ENV["GMAIL_PASSWORD"]
  }



  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin


  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.eager_load = false

  class LoggerFormatWithTime
    def call(severity, timestamp, progname, msg)
      format = "[%s] %5s -- %s: %s\n"
      format % ["#{timestamp.strftime("%Y/%m/%d %H:%M:%S")}.#{'%06d' % timestamp.usec.to_s}", severity, progname, String === msg ? msg : msg.inspect]
    end
  end

  config.log_level = :error
  FileUtils.mkdir_p( Rails.root.join("log") )
  config.logger = Logger.new(Rails.root.join("log/development.log"), 5, 1.megabytes)
  config.logger.formatter = LoggerFormatWithTime.new
  Mongoid.logger.level = Logger::WARN
  Mongoid.logger.formatter = LoggerFormatWithTime.new
  Mongo::Logger.logger.level = Logger::WARN
  Mongo::Logger.logger.formatter = LoggerFormatWithTime.new
end
