class Notifier < ActionMailer::Base
  default from: Settings.reply_email

  def group_invitation(membership_id)
    @membership = Membership.find(membership_id)
    @group = @membership.group

    mail(to: @membership.invitation_email || @membership.user.email,
         from: @membership.invited_by_user.try(:email) || Settings.reply_email,
         subject: "[#{Settings.app_name}] You've been invited to the #{@membership.group.name} group")
  end

  def new_answer(question_id, user_id)
    @question = Question.find(question_id)
    @user = User.find(user_id)

    mail(to: @user.email, subject: "[#{Settings.app_name}] New answer for '#{@question.subject}'")
  end

  def new_question(question_id, user_id)
    @question = Question.find(question_id)
    @user = User.find(user_id)

    mail(to: @user.email, subject: "[#{Settings.app_name}] New question for you: '#{@question.subject}'")
  end

  def new_comment(question_id, user_id)
    @question = Question.find(question_id)
    @user = User.find(user_id)

    mail(to: @user.email, subject: "[#{Settings.app_name}] New comment for '#{@question.subject}'")
  end

end
