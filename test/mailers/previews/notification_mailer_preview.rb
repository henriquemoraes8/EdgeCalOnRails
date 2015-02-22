# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def notification_mailer_preview
    NotificationMailer.notification_email(User.first)
  end
end
