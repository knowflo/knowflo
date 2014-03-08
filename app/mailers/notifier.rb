class Notifier < ActionMailer::Base
  default from: Settings.reply_email

  def group_invitation(membership_id)
    @membership = Membership.find(membership_id)
    @group = @membership.group

    mail(:to => @membership.invitation_email || @membership.user.email,
         :from => @membership.invited_by_user.try(:email) || Settings.reply_email,
         :subject => "You've been invited to the #{@membership.group.name} group")
  end

end
