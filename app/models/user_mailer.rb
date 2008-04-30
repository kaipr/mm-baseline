class UserMailer < ActionMailer::Base
  def signup_notification(user)
    @recipients  = "#{user.email}"
    @from        = "ADMINEMAIL"
    @subject     = "[YOURSITE] Bitte aktivieren Sie Ihr Benutzerkonto"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = "http://YOURSITE/activate/#{user.activation_code}"
  end
end
