require "spec_helper"

describe Notifier do
  describe 'group_invitation' do
    before(:each) do
      @membership = FactoryGirl.create(:invitation, :invitation_email => 'invited@zerosum.org')
      @membership.group.update_attribute(:welcome_message, 'hello nurse')
      @mail = Notifier.group_invitation(@membership.id)
    end

    it 'should send email to the invited user' do
      @mail.to.should include('invited@zerosum.org')
    end

    it 'should be from the user who sent the invitation' do
      @mail.from.should include(@membership.invited_by_user.email)
    end

    it 'should contain the group name and acceptance url' do
      @mail.subject.should match(/#{@membership.group.name}/)

      @mail.body.parts.each do |part|
        email_body(part).should match(@membership.reload.token)
      end
    end

    it 'should include the group welcome message if set' do
      @mail.body.parts.each do |part|
        email_body(part).should match(/hello nurse/)
      end
    end
  end

  describe 'new_question' do
    let(:following_user) { FactoryGirl.create(:user) }
    let(:ignored_user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }
    let(:question) { FactoryGirl.create(:question, group: group) }
    let(:mail) { Notifier.new_question(question.id) }

    before(:each) do
      FactoryGirl.create(:membership, group: group, user: following_user, notifications_enabled: true)
      FactoryGirl.create(:membership, group: group, user: ignored_user, notifications_enabled: false)
    end

    it 'sends email to group members who have notifications enabled' do
      email_recipients(mail).should include(following_user.email)
    end

    it 'does not send email to group members who have notifications disabled' do
      email_recipients(mail).should_not include(ignored_user.email)
    end

    it 'does not send email to the user who created the question' do
      email_recipients(mail).should_not include(question.user.email)
    end

    it 'contains the new question subject and body' do
      mail.subject.should match(/#{question.subject}/)

      mail.body.parts.each do |part|
        email_body(part).should match(question.body)
      end
    end
  end

  describe 'new_answer' do
    let(:following_user) { FactoryGirl.create(:user) }
    let(:ignored_user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }
    let(:question) { FactoryGirl.create(:question, group: group) }
    let(:answer) { FactoryGirl.create(:answer, question: question) }
    let(:mail) { Notifier.new_answer(answer.id) }

    before(:each) do
      FactoryGirl.create(:membership, group: group, user: following_user)
      FactoryGirl.create(:membership, group: group, user: ignored_user)
      FactoryGirl.create(:following, question: question, user: following_user)
    end

    it 'sends email to group members who have notifications enabled' do
      email_recipients(mail).should include(following_user.email)
    end

    it 'does not send email to group members who have notifications disabled' do
      email_recipients(mail).should_not include(ignored_user.email)
    end

    it 'does not send email to the user who created the question' do
      email_recipients(mail).should_not include(answer.user.email)
    end

    it 'contains the question subject and the new answer text' do
      mail.subject.should match(/#{question.subject}/)

      mail.body.parts.each do |part|
        email_body(part).should match(answer.body)
      end
    end
  end
end

def email_body(part)
  part.to_s.gsub("=\r\n", "")
end

def email_recipients(mail)
  value = mail.header['X-SMTPAPI'].value
  if value.present?
    JSON.parse(value)['to']
  else
    []
  end
end
