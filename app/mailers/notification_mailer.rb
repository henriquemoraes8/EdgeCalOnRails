class NotificationMailer < ApplicationMailer

  require 'mailgun'

  def notification_email(user)
    @user = user
    mail(to: @user.email, subject: 'Notification Email')
  end

  def to_do_reminder_email(user, to_do)
    @user = user
    @to_do = to_do

    mg_client = Mailgun::Client.new "key-345efdd486ec59509f9161b99b78d333"

    # Define your message parameters
    message_params = {:from => 'notifications@sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org',  
      :to      => 'wes.koorbusch@gmail.com',
      :subject => 'To-Do Reminder!',
      :text    => 'This is a to-do reminder for you!'}

    mg_client.send_message "sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org", message_params

    # mail(to: 'wes.koorbusch@gmail.com', subject: 'To-Do Notification Email')
  end

  def subscription_reminder_email(user, subscription)
    puts user
    puts subscription
    #@user = user
    #@event = subscription.subscribed_event

    mg_client = Mailgun::Client.new "key-345efdd486ec59509f9161b99b78d333"

    # Define your message parameters
    message_params = {:from => 'notifications@sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org',  
      :to      => 'wes.koorbusch@gmail.com',
      :subject => 'Subscription Reminder!',
      :text    => 'This is a subscription reminder for you!'}

    mg_client.send_message "sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org", message_params

    # mail(to: 'wes.koorbusch@gmail.com', subject: 'Event Notification Email')
  end

  # FOR TESTING EMAILS
  def send_notification_email
    # First, instantiate the Mailgun Client with your API key
    mg_client = Mailgun::Client.new "key-345efdd486ec59509f9161b99b78d333"

    # Define your message parameters
    message_params = {:from => 'notifications@sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org',  
      :to      => 'wes.koorbusch@gmail.com',
      :subject => 'The Ruby SDK is awesome!',
      :text    => 'It is really easy to send a message!'}

    # Send your message through the client
    mg_client.send_message "sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org", message_params
  end

end