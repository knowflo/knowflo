class Notifier < ActionMailer::Base
  include SendGrid

  sendgrid_category :use_subject_lines

  default reply_to: Settings.reply_email,
    return_path: Settings.reply_email,
    from: Settings.reply_email

  def group_invitation(membership_id)
    @membership = Membership.find(membership_id)
    @group = @membership.group

    mail(to: @membership.invitation_email || @membership.user.email,
         from: @membership.invited_by_user.try(:email) || Settings.reply_email,
         subject: "[#{Settings.app_name}] You've been invited to the #{@membership.group.name} group")
  end

  def new_question(question_id)
    @question = Question.find(question_id)
    @user = @question.user

    sendgrid_recipients @question.group.following_users.map(&:email)

    mail(to: @user.email, subject: "[#{Settings.app_name}] New question for you: '#{@question.subject}'")
  end

  def new_answer(answer_id)
    @answer = Answer.find(answer_id)
    @question = @answer.question
    @user = @question.user

    sendgrid_recipients @question.following_users.map(&:email)

    mail(to: @question.user.email, subject: "[#{Settings.app_name}] New answer for '#{@question.subject}'")
  end

end
