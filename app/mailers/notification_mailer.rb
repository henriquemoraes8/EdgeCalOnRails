class NotificationMailer < ApplicationMailer
  
  default from: "CHANGETHIS@DOMAIN.com"

  def notification_email(user)
    @user = user
    mail(to: @user.email, subject: 'Notification Email')
  end

  def to_do_reminder_email(user, to_do)
    @user = user
    @to_do = to_do
    mail(to: 'hrm8@duke.edu', subject: 'Notification Email')
  end
  
end
