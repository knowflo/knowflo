Knowflo::Application.config.middleware.use ExceptionNotification::Rack,
  email: {
    email_prefix: "[#{Settings.app_name}] ",
    sender_address: Settings.exception_sender,
    exception_recipients: Settings.admin_emails
  }
