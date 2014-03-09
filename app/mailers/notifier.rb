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

  def new_question(question_id, sender_id=nil)
    @question = Question.find(question_id)
    @user = @question.user
    sender = sender_id.present? ? User.find(sender_id).email : nil

    sendgrid_recipients @question.group.following_users.map(&:email).reject { |email| email == sender }
    mail(to: @user.email, subject: "[#{Settings.app_name}] New question for you: '#{@question.subject}'")
  end

  def new_answer(answer_id, sender_id=nil)
    @answer = Answer.find(answer_id)
    @question = @answer.question
    @user = @question.user
    sender = sender_id.present? ? User.find(sender_id).email : nil

    sendgrid_recipients @question.following_users.map(&:email).reject { |email| email == sender }
    mail(to: @question.user.email, subject: "[#{Settings.app_name}] New answer for '#{@question.subject}'")
  end

end
