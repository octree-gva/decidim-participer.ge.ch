class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("FROM_MAILER_ADDRESS")

  layout 'mailer'

end
