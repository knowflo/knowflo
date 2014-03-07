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
end

def email_body(part)
  part.to_s.gsub("=\r\n", "")
end

