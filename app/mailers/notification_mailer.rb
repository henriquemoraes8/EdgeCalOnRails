class NotificationMailer < ApplicationMailer

  require 'mailgun'

  def send_html_email(user, html)
    @user = user
    puts "USER EMAIL IS: " + user.email

    mg_client = Mailgun::Client.new "key-345efdd486ec59509f9161b99b78d333"

    # Define your message parameters
    puts "SENDING EMAIL HERE"
    message_params = {:from => 'notifications@sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org',  
      :to      => user.email, #'wes.koorbusch@gmail.com',
      :subject => 'Your Events!',
      :html    => html
    }

    mg_client.send_message "sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org", message_params


    # get_visible_events
    # get_busy_events
    # get_modifiable_events
    # get_requested_events
    # get_time_slot_created_events
  end

  def notification_email(user)
    @user = user
    mail(to: @user.email, subject: 'Notification Email')
  end

  def to_do_reminder_email(user, to_do)
    @user = user
    @to_do = to_do
    puts "USER EMAIL IS: " + user.email

    mg_client = Mailgun::Client.new "key-345efdd486ec59509f9161b99b78d333"

    # Define your message parameters
    message_params = {:from => 'notifications@sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org',  
      :to      => user.email, #'wes.koorbusch@gmail.com',
      :subject => 'To-Do Reminder!',
      :text    => 'This is a reminder to check your to-do list!',
    }

    mg_client.send_message "sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org", message_params

  end

  def to_do_reminder_email(user, to_do)
    @user = user
    @to_do = to_do
    puts "USER EMAIL IS: " + user.email

    mg_client = Mailgun::Client.new "key-345efdd486ec59509f9161b99b78d333"

    # Define your message parameters
    message_params = {:from => 'notifications@sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org',  
      :to      => user.email, #'wes.koorbusch@gmail.com',
      :subject => 'To-Do Reminder!',
      :html    => 'notofication_mailer/notification_email.html.erb',
    }

    mg_client.send_message "sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org", message_params

    # mail(to: 'wes.koorbusch@gmail.com', subject: 'To-Do Notification Email')
  end

  def subscription_reminder_email(user, subscription)
    @user = user
    @event = subscription.subscribed_event
    puts "USER EMAIL IS: " + user.email

    mg_client = Mailgun::Client.new "key-345efdd486ec59509f9161b99b78d333"

    # Define your message parameters
    message_params = {:from => 'notifications@sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org',  
      :to      => user.email, #'wes.koorbusch@gmail.com',
      :subject => 'Subscription Reminder!',
      :text    => 'This is a reminder to check your subscriptions!'}

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