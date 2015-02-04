class NotificationMailer < ApplicationMailer
  
  default from: "CHANGETHIS@DOMAIN.com"

  def notification_email(user)
    @user = user
    mail(to: @user.email, subject: 'Notification Email')
  end
  
end
