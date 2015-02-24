class ApplicationMailer < ActionMailer::Base

	require 'mailgun'
  	default from: "notifications@sandboxb478b65d1ad94458945aa2e6e6549bba.mailgun.org"
  	layout 'mailer'
  	
end
