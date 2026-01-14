class UserMailer < ApplicationMailer
  # Send welcome email to new users
  def welcome_email(user)
    @user = user
    mail(
      to: @user.email,
      subject: 'Welcome to Outfitmaker! 👋'
    )
  end

  # Send notification when user reaches activation milestone (5 items)
  def activation_email(user)
    @user = user
    mail(
      to: @user.email,
      subject: '🎉 You\'ve activated your wardrobe!'
    )
  end
end
