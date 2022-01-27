class UserMailer < ApplicationMailer
  def test_email
    @user = User.first
    mail(to: @user.email, subject: "Test DSB")
  end
end
